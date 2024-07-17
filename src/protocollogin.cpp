// Copyright 2023 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#include "otpch.h"

#include "protocollogin.h"

#include "ban.h"
#include "base64.h"
#include "configmanager.h"
#include "game.h"
#include "iologindata.h"
#include "outputmessage.h"
#include "rsa.h"
#include "tasks.h"

extern Game g_game;

void ProtocolLogin::disconnectClient(const std::string& message)
{
	auto output = OutputMessagePool::getOutputMessage();

	output->addByte(0x0A);
	output->addString(message);
	send(output);

	disconnect();
}

void ProtocolLogin::getCharacterList(const std::string& accountName, const std::string& password)
{
	Database& db = Database::getInstance();

	DBResult_ptr result = db.storeQuery(fmt::format(
	    "SELECT `id`, UNHEX(`password`) AS `password`, `secret`, `premium_ends_at` FROM `accounts` WHERE `name` = {:s} OR `email` = {:s}",
	    db.escapeString(accountName), db.escapeString(accountName)));
	if (!result) {
		disconnectClient("Account name or password is not correct.");
		return;
	}

	if (transformToSHA1(password) != result->getString("password")) {
		disconnectClient("Account name or password is not correct.");
		return;
	}

	auto id = result->getNumber<uint32_t>("id");
	auto premiumEndsAt = result->getNumber<time_t>("premium_ends_at");

	std::vector<std::string> characters = {};
	result = db.storeQuery(fmt::format(
	    "SELECT `name` FROM `players` WHERE `account_id` = {:d} AND `deletion` = 0 ORDER BY `name` ASC", id));
	if (result) {
		do {
			characters.emplace_back(result->getString("name"));
		} while (result->next());
	}

	auto output = OutputMessagePool::getOutputMessage();

	// todo: add motd into config.lua and load in ConfigManager
	// const std::string& motd = getString(ConfigManager::MOTD);
	// if (!motd.empty()) {
	//	// Add MOTD
	//	output->addByte(0x14);
	//	output->addString(fmt::format("{:d}\n{:s}", g_game.getMotdNum(), motd));
	// }

	// Add char list
	output->addByte(0x64);

	uint8_t size = std::min<size_t>(std::numeric_limits<uint8_t>::max(), characters.size());
	output->addByte(size);

	for (uint8_t i = 0; i < size; i++) {
		const auto& character = characters[i];
		output->addString(character);
		output->addString(getString(ConfigManager::SERVER_NAME));
		output->add<uint32_t>(getIPFromString(getString(ConfigManager::IP)));
		output->add<uint16_t>(getNumber(ConfigManager::GAME_PORT));
	}

	// Add premium days
	if (getBoolean(ConfigManager::FREE_PREMIUM)) {
		output->add<uint16_t>(0xFFFF); // client displays free premium
	} else {
		output->add<uint16_t>(std::max<time_t>(0, premiumEndsAt - time(nullptr)) / 86400);
	}

	send(output);

	disconnect();
}

// Character list request
void ProtocolLogin::onRecvFirstMessage(NetworkMessage& msg)
{
	if (g_game.getGameState() == GAME_STATE_SHUTDOWN) {
		disconnect();
		return;
	}

	msg.skipBytes(2); // client OS

	uint16_t version = msg.get<uint16_t>();
	if (version <= 822) {
		setChecksumMode(CHECKSUM_DISABLED);
	}

	if (version <= 760) {
		disconnectClient(fmt::format("Only clients with protocol {:s} allowed!", CLIENT_VERSION_STR));
		return;
	}

	if (version >= 971) {
		msg.skipBytes(17);
	} else {
		msg.skipBytes(12);
	}
	/*
	 * Skipped bytes:
	 * 4 bytes: protocolVersion
	 * 12 bytes: dat, spr, pic signatures (4 bytes each)
	 * 1 byte: 0
	 */

	if (!Protocol::RSA_decrypt(msg)) {
		disconnect();
		return;
	}

	xtea::key key;
	key[0] = msg.get<uint32_t>();
	key[1] = msg.get<uint32_t>();
	key[2] = msg.get<uint32_t>();
	key[3] = msg.get<uint32_t>();
	enableXTEAEncryption();
	setXTEAKey(std::move(key));

	if (version < CLIENT_VERSION_MIN || version > CLIENT_VERSION_MAX) {
		disconnectClient(fmt::format("Only clients with protocol {:s} allowed!", CLIENT_VERSION_STR));
		return;
	}

	if (g_game.getGameState() == GAME_STATE_STARTUP) {
		disconnectClient("Gameworld is starting up. Please wait.");
		return;
	}

	if (g_game.getGameState() == GAME_STATE_MAINTAIN) {
		disconnectClient("Gameworld is under maintenance.\nPlease re-connect in a while.");
		return;
	}

	auto connection = getConnection();
	if (!connection) {
		return;
	}

	if (const auto& banInfo = IOBan::getIpBanInfo(connection->getIP())) {
		disconnectClient(fmt::format("Your IP has been banned until {:s} by {:s}.\n\nReason specified:\n{:s}",
		                             formatDateShort(banInfo->expiresAt), banInfo->bannedBy, banInfo->reason));
		return;
	}

	auto accountName = msg.getString();
	if (accountName.empty()) {
		disconnectClient("Invalid account name.");
		return;
	}

	auto password = msg.getString();
	if (password.empty()) {
		disconnectClient("Invalid password.");
		return;
	}

	g_dispatcher.addTask([=, thisPtr = std::static_pointer_cast<ProtocolLogin>(shared_from_this()),
	                      accountName = std::string{accountName}, password = std::string{password}]() {
		thisPtr->getCharacterList(accountName, password);
	});
}

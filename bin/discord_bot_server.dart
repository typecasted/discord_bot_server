import 'dart:developer';
import "package:discord_bot_server/appwrite_utils.dart";
import 'package:discord_bot_server/games/games.dart';
import 'package:discord_bot_server/games/would_you_rather.dart';
import 'package:discord_bot_server/utils.dart';
import 'package:nyxx/nyxx.dart';
import 'package:discord_bot_server/token.dart';

Future<void> main() async {
  print("Hello, world");
  runBot();
}

dynamic runBot() async {
  // Create new bot instance
  final bot = NyxxFactory.createNyxxWebsocket(
    /* add your token here */ token,
    GatewayIntents.allUnprivileged,
  )
    ..registerPlugin(Logging()) // Default logging plugin
    ..registerPlugin(
        CliIntegration()) // Cli integration for nyxx allows stopping application via SIGTERM and SIGKILl
    ..registerPlugin(
        IgnoreExceptions()) // Plugin that handles uncaught exceptions that may occur
    ..connect();

  // Listen to ready event. Invoked when bot is connected to all shards. Note that cache can be empty or not incomplete.
  bot.eventsWs.onReady.listen(
    (e) {
      logger.i("Bot's ready");
    },
  );

  // Listen to all incoming messages
  bot.eventsWs.onMessageReceived.listen(
    (e) async {
      if (e.message.content.contains("!")) {
        logger.i(
            "${e.message.author.username} entered command = ${e.message.content}");
        switch (e.message.content) {
          // Check if message content equals "!ping"
          case "!ping":
            // Send "Pong!" to channel where message was received
            e.message.channel.sendMessage(MessageBuilder.content("Pong!"));
            break;

          case "!myName":
            e.message.channel.sendMessage(
              MessageBuilder.content(
                e.message.author.username.toString(),
              ),
            );
            break;

          case "!serverName":
            final guildId = e.message.guild?.id;
            e.message.channel.sendMessage(
              MessageBuilder.content(
                e.message.client.guilds.values
                    .firstWhere((element) => element.id == guildId)
                    .name,
              ),
            );
            break;

          case "!talkToMe":
            e.message.member?.user.download().then(
                  (value) => value.sendMessage(
                    MessageBuilder.content(
                      "Hey sweetheart!!!",
                    ),
                  ),
                );
            break;

          case "!letMeJoin":
            userRegistrationProcess(e);
            break;

          case "!wouldYouRather":
            final question =
                Games.getQuestion(questionList: wouldYouratherQuestionList);
            logger.i("Question = $question");
            e.message.channel.sendMessage(
              MessageBuilder.content(
                question,
              ),
            );
            break;

          case "!helpMe":
            e.message.channel.sendMessage(
              MessageBuilder.content(
                "Hey there! Myself experimentBot.\nWant to play would you rather game with me? type \"!wouldYouRather\"",
              ),
            );
            break;

          case "!users":
            log("entered in users area!");
            e.message.guild!.download().then(
              (value) {
                value.fetchMembers(limit: 2).listen(
                  (event) {
                    event.guild.download().then(
                          (value) => log("name : ${value.name}"),
                        );
                  },
                );
              },
            );
            break;
        }
      }
    },
  );
}

Future<void> userRegistrationProcess(IMessageReceivedEvent e) async {
  /// to check if user is registered or not
  await appwriteUtils
      .isUserRegistered(
    tagline: e.message.author.tag.toString().split("#").last,
  )
      .then(
    (value) async {
      /// if user is registered
      if (value) {
        e.message.channel.sendMessage(
            MessageBuilder.content("You are already registered!!!"));
      } else {
        /// if user is not registered
        await appwriteUtils
            .addUser(
          userName: e.message.author.tag.toString().split("#").first,
          tagLine: e.message.author.tag.toString().split("#").last,
        )
            .then(
          (value) {
            /// if user is registered successfully
            if (value) {
              e.message.channel.sendMessage(
                MessageBuilder.content("You are registered successfully!!!"),
              );
            } else {
              /// if user is registeration fails
              e.message.channel.sendMessage(
                MessageBuilder.content(
                    "Something went wrong :( , please try later."),
              );
            }
          },
        );
      }
    },
  );
}

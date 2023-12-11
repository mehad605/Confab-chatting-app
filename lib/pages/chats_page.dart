import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:timeago/timeago.dart' as timeago;

//Providers
import '../providers/authentication_provider.dart';
import '../providers/chats_page_provider.dart';

//Services
import '../services/navigation_service.dart';

//Pages
import '../pages/chat_page.dart';
import '../pages/user_profile.dart';

//Widgets
import '../widgets/top_bar.dart';
import '../widgets/custom_list_view_tiles.dart';

//Models
import '../models/chat.dart';
import '../models/chat_user.dart';
import '../models/chat_message.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ChatsPageState();
  }
}

class _ChatsPageState extends State<ChatsPage> {
  late double _deviceHeight;
  late double _deviceWidth;

  late AuthenticationProvider _auth;
  late NavigationService _navigation;
  late ChatsPageProvider _pageProvider;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthenticationProvider>(context);
    _navigation = GetIt.instance.get<NavigationService>();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ChatsPageProvider>(
          create: (_) => ChatsPageProvider(_auth),
        ),
      ],
      child: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Builder(
      builder: (BuildContext context) {
        _pageProvider = context.watch<ChatsPageProvider>();
        return SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _deviceWidth * 0.03,
              vertical: _deviceHeight * 0.02,
            ),
            height: _deviceHeight * 0.98,
            width: _deviceWidth * 0.97,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Consumer<AuthenticationProvider>(
                      builder: (context, authProvider, _) {
                        return FutureBuilder<String?>(
                          future: authProvider.getCurrentUserImageURL(),
                          builder: (BuildContext context,
                              AsyncSnapshot<String?> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator(); // Show a loading indicator while fetching the image URL
                            } else {
                              if (snapshot.hasData && snapshot.data != null) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UserPage(), // Replace with your UserProfile page
                                      ),
                                    );
                                  },
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(snapshot
                                        .data!), // Use the retrieved URL
                                    radius: 15,
                                  ),
                                );
                              } else {
                                return const Text(
                                    'No Image'); // Placeholder if no image URL available
                              }
                            }
                          },
                        );
                      },
                    ),
                    const Text(
                      'Chats',
                      style: TextStyle(
                        fontFamily: 'Pacifico',
                        color: Color.fromARGB(255, 246, 241, 171),
                        fontSize: 30, // Decreased from 40 to 30
                        fontWeight:
                            FontWeight.w400, // Decreased from w600 to w400
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout,
                          color: Color.fromRGBO(112, 242, 114, 1)),
                      onPressed: () {
                        _auth.logout();
                      },
                    ),
                  ],
                ),
                const Divider(
                  color: Color.fromARGB(255, 246, 241, 171),
                ), // Add a divider to separate the top bar from the rest of the page
                _chatsList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _chatsList() {
    List<Chat>? chats = _pageProvider.chats;
    return Expanded(
      child: (() {
        if (chats != null) {
          if (chats.isNotEmpty) {
            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (BuildContext context, int index) {
                return _chatTile(
                  chats[index],
                );
              },
            );
          } else {
            return const Center(
              child: Text(
                "No Chats Found.",
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
      })(),
    );
  }

  Widget _chatTile(Chat chat) {
    List<ChatUser> recipients = chat.recepients();
    bool isActive = recipients.any((user) => user.wasRecentlyActive());
    String lastMessageContent = "";
    String timestamp = "";

    if (chat.messages.isNotEmpty) {
      lastMessageContent = chat.messages.last.type != MessageType.TEXT
          ? "Media Attachment"
          : chat.messages.last.content;

      timestamp = chat.messages.last.sentTime != null
          ? timeago.format(chat.messages.last.sentTime,
              locale: 'en_short') // 'en_short' for short time descriptions
          : "";
    }

    return GestureDetector(
      onTap: () {
        _navigation.navigateToPage(
          ChatPage(chat: chat),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.blueGrey[800],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(chat.imageURL()),
          ),
          title: Text(
            chat.title(),
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
          subtitle: Text(
            lastMessageContent,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isActive)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                ),
              const SizedBox(width: 5),
              if (!isActive)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
              const SizedBox(width: 5),
            ],
          ),
        ),
      ),
    );
  }
}

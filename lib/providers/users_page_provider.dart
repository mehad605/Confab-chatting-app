import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

//Services
import '../services/database_service.dart';
import '../services/navigation_service.dart';

//Providers
import '../providers/authentication_provider.dart';

//Models
import '../models/chat_user.dart';
import '../models/chat.dart';

//Pages
import '../pages/chat_page.dart';

class UsersPageProvider extends ChangeNotifier {
  AuthenticationProvider _auth;

  late DatabaseService _database;
  late NavigationService _navigation;


  bool _isSearching = false; // Added variable

  bool get isSearching => _isSearching; // Getter for _isSearching

  List<ChatUser>? users;
  late List<ChatUser> _selectedUsers;

  List<ChatUser> get selectedUsers {
    return _selectedUsers;
  }

  UsersPageProvider(this._auth) {
    _selectedUsers = [];
    _database = GetIt.instance.get<DatabaseService>();
    _navigation = GetIt.instance.get<NavigationService>();
    getUsers();
  }

  // Method to clear users
  void clearUsers() {
    users = null;
    notifyListeners();
  }

  // New methods to start and stop searching
  void startSearching() {
    _isSearching = true;
    notifyListeners();
  }

  void stopSearching() {
    _isSearching = false;
    notifyListeners();
  }


  @override
  void dispose() {
    super.dispose();
  }

  void getUsers({String? name}) async {
    _selectedUsers = [];
    try {
      if (name != null && name.isNotEmpty) {
        // Start searching when the user enters a name
        startSearching();
        _database.getUsers(name: name).then(
          (_snapshot) {
            users = _snapshot.docs.map(
              (_doc) {
                Map<String, dynamic> _data = _doc.data() as Map<String, dynamic>;
                _data["uid"] = _doc.id;
                return ChatUser.fromJSON(_data);
              },
            ).toList();
            notifyListeners();
            // Stop searching when the search is complete
            stopSearching();
          },
        );
      } else {
        // Clear the users list when the search field is empty
        clearUsers();
      }
    } catch (e) {
      print("Error getting users.");
      print(e);
      // Stop searching in case of an error
      stopSearching();
    }
  }



  void updateSelectedUsers(ChatUser _user) {
    if (_selectedUsers.contains(_user)) {
      _selectedUsers.remove(_user);
    } else {
      _selectedUsers.add(_user);
    }
    notifyListeners();
  }

  void createChat() async {
    try {
      //Create Chat
      List<String> _membersIds =
          _selectedUsers.map((_user) => _user.uid).toList();
      _membersIds.add(_auth.user.uid);
      bool _isGroup = _selectedUsers.length > 1;
      DocumentReference? _doc = await _database.createChat(
        {
          "is_group": _isGroup,
          "is_activity": false,
          "members": _membersIds,
        },
      );
      //Navigate To Chat Page
      List<ChatUser> _members = [];
      for (var _uid in _membersIds) {
        DocumentSnapshot _userSnapshot = await _database.getUser(_uid);
        Map<String, dynamic> _userData =
            _userSnapshot.data() as Map<String, dynamic>;
        _userData["uid"] = _userSnapshot.id;
        _members.add(
          ChatUser.fromJSON(
            _userData,
          ),
        );
      }
      ChatPage _chatPage = ChatPage(
        chat: Chat(
            uid: _doc!.id,
            currentUserUid: _auth.user.uid,
            members: _members,
            messages: [],
            activity: false,
            group: _isGroup),
      );
      _selectedUsers = [];
      notifyListeners();
      _navigation.navigateToPage(_chatPage);
    } catch (e) {
      print("Error creating chat.");
      print(e);
    }
  }
}
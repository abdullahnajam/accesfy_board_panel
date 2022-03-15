import 'package:accessify/models/board_member_model.dart';
import 'package:flutter/cupertino.dart';

class UserDataProvider extends ChangeNotifier {
  BoardMemberModel? boardMemberModel;
  void setUserData(BoardMemberModel data) {
    this.boardMemberModel = data;
    notifyListeners();
  }


}

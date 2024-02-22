import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:PiliPalaX/http/video.dart';
import 'package:PiliPalaX/models/common/reply_type.dart';
import 'package:PiliPalaX/models/video/reply/item.dart';
import 'package:PiliPalaX/utils/feed_back.dart';

import '../../../../common/constants.dart';
import '../reply/reply_emote/view.dart';

class VideoReplyNewDialog extends StatefulWidget {
  final int? oid;
  final int? root;
  final int? parent;
  final ReplyType? replyType;
  final ReplyItemModel? replyItem;

  const VideoReplyNewDialog({
    super.key,
    this.oid,
    this.root,
    this.parent,
    this.replyType,
    this.replyItem,
  });

  @override
  State<VideoReplyNewDialog> createState() => _VideoReplyNewDialogState();
}

class _VideoReplyNewDialogState extends State<VideoReplyNewDialog>
    with WidgetsBindingObserver {
  final TextEditingController _replyContentController = TextEditingController();
  final FocusNode replyContentFocusNode = FocusNode();
  final GlobalKey _formKey = GlobalKey<FormState>();
  bool isShowEmote = false;

  @override
  void initState() {
    super.initState();
    // 监听输入框聚焦
    // replyContentFocusNode.addListener(_onFocus);
    // 界面观察者 必须
    WidgetsBinding.instance.addObserver(this);
    // 自动聚焦
    _autoFocus();
  }

  _autoFocus() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (context.mounted) {
      FocusScope.of(context).requestFocus(replyContentFocusNode);
    }
  }

  Future submitReplyAdd() async {
    feedBack();
    String message = _replyContentController.text;
    var result = await VideoHttp.replyAdd(
      type: widget.replyType ?? ReplyType.video,
      oid: widget.oid!,
      root: widget.root!,
      parent: widget.parent!,
      message: widget.replyItem != null && widget.replyItem!.root != 0
          ? ' 回复 @${widget.replyItem!.member!.uname!} : $message'
          : message,
    );
    if (result['status']) {
      SmartDialog.showToast(result['data']['success_toast']);
      Get.back(result: {
        'data': ReplyItemModel.fromJson(result['data']['reply'], ''),
      });
    } else {
      SmartDialog.showToast(result['msg']);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _replyContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double keyboardHeight = EdgeInsets.fromViewPadding(
            View.of(context).viewInsets, View.of(context).devicePixelRatio)
        .bottom;
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        color: Theme.of(context).colorScheme.background,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 200,
              minHeight: 120,
            ),
            child: Container(
              padding: const EdgeInsets.only(
                  top: 12, right: 15, left: 15, bottom: 10),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: TextField(
                    controller: _replyContentController,
                    minLines: 1,
                    maxLines: null,
                    autofocus: false,
                    focusNode: replyContentFocusNode,
                    decoration: const InputDecoration(
                        hintText: "输入回复内容",
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 14,
                        )),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
          Container(
            height: 52,
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButton(
                    onPressed: () async {
                      FocusScope.of(context)
                          .requestFocus(replyContentFocusNode);
                      await Future.delayed(const Duration(milliseconds: 200));
                      setState(() {
                        isShowEmote = false;
                      });
                    },
                    icon: Icon(Icons.keyboard,
                        size: 22,
                        color: Theme.of(context).colorScheme.onBackground),
                    highlightColor:
                        Theme.of(context).colorScheme.onInverseSurface,
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      backgroundColor:
                          MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed) || !isShowEmote) {
                          return Theme.of(context).highlightColor;
                        }
                        // 默认状态下，返回透明颜色
                        return Colors.transparent;
                      }),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 36,
                  height: 36,
                  child: IconButton(
                    onPressed: () {
                      //收起输入法
                      FocusScope.of(context).unfocus();
                      // 弹出表情选择
                      setState(() {
                        isShowEmote = true;
                      });
                    },
                    icon: Icon(Icons.emoji_emotions,
                        size: 22,
                        color: Theme.of(context).colorScheme.onBackground),
                    highlightColor:
                        Theme.of(context).colorScheme.onInverseSurface,
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      backgroundColor:
                          MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed) || isShowEmote) {
                          return Theme.of(context).highlightColor;
                        }
                        // 默认状态下，返回透明颜色
                        return Colors.transparent;
                      }),
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                    onPressed: () => submitReplyAdd(), child: const Text('发送'))
              ],
            ),
          ),
          if (!isShowEmote)
            SizedBox(
              width: double.infinity,
              height: keyboardHeight,
            ),
          if (isShowEmote)
            SizedBox(
              width: double.infinity,
              height: 310,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: StyleString.safeSpace),
                child: EmoteTab(
                  onEmoteTap: onEmoteTap,
                ),
              ),
            )
        ],
      ),
    );
  }

  void onEmoteTap(String emoteString) {
    // 在光标处插入表情
    final String currentText = _replyContentController.text;
    final TextSelection selection = _replyContentController.selection;
    final String newText = currentText.replaceRange(
      selection.start,
      selection.end,
      emoteString,
    );
    _replyContentController.text = newText;
    final int newCursorIndex = selection.start + emoteString.length;
    _replyContentController.selection = selection.copyWith(
      baseOffset: newCursorIndex,
      extentOffset: newCursorIndex,
    );
  }
}

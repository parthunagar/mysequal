import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:peloton/views/chat/flat_chat_message.dart';

enum ScrollType {
  fixedHeader,
  floatingHeader,
}

class FlatPageWrapper extends StatefulWidget {
  final List<Widget> children;
  final Color backgroundColor;
  final Widget header;
  final ScrollType scrollType;
  final Widget footer;
  final bool reverseBodyList;
  final Stream<FlatChatMessage> stream;

  FlatPageWrapper(
      {this.children,
      this.backgroundColor,
      this.header,
      this.scrollType,
      this.footer,
      this.reverseBodyList,
      this.stream});

  @override
  _FlatPageWrapperState createState() => _FlatPageWrapperState();
}

class _FlatPageWrapperState extends State<FlatPageWrapper> {
  @override
  Widget build(BuildContext context) {
    print(widget.children.length);
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,

          child: Container(
        color: widget.backgroundColor ?? Theme.of(context).primaryColorLight,
        child: _PageBodyWidget(
          scrollType: widget.scrollType,
          children: widget.children,
          header: widget.header,
          footer: widget.footer,
          reverseBodyList: widget.reverseBodyList,
          stream: widget.stream,
        ),
      ),
    );
  }
}

class _PageBodyWidget extends StatefulWidget {
  final List<Widget> children;
  final Widget header;
  final ScrollType scrollType;
  final Widget footer;
  final bool reverseBodyList;
  final Stream<FlatChatMessage> stream;

  _PageBodyWidget(
      {this.children,
      this.header,
      this.scrollType,
      this.footer,
      this.reverseBodyList,
      this.stream});

  @override
  __PageBodyWidgetState createState() => __PageBodyWidgetState();
}

class __PageBodyWidgetState extends State<_PageBodyWidget> {
  addBuind() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      scrollControler.animateTo(
        scrollControler.position.maxScrollExtent,
        duration: const Duration(milliseconds: 10),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void initState() {
    addBuind();
    super.initState();
  }

  final scrollControler = ScrollController();
  @override
  Widget build(BuildContext context) {
    
    double inputPadding() {
      if (widget.scrollType != null &&
          widget.scrollType == ScrollType.floatingHeader) {
        return 24.0;
      } else {
        return 0.0;
      }
    }

    double bottomPadding() {
      if (widget.footer != null &&
          widget.scrollType == ScrollType.floatingHeader) {
        return 80.0;
      } else {
        return 12.0;
      }
    }

    if (widget.scrollType != null &&
        widget.scrollType == ScrollType.floatingHeader) {
      return Stack(
        children: [
          Positioned(
            child: ScrollConfiguration(
              behavior: GlowRemoveScrollBehaviour(),
              child: ListView(
                reverse: widget.reverseBodyList ?? false,
                padding: EdgeInsets.only(
                  top: 122.0,
                  bottom: bottomPadding(),
                ),
                children: widget.children,
              ),
            ),
          ),
          Positioned(
            child: widget.header ?? Container(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(inputPadding()),
              child: widget.footer,
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          widget.header ?? Container(),
          Expanded(
              child: ScrollConfiguration(
            behavior: GlowRemoveScrollBehaviour(),
            child: StreamBuilder(
              stream: widget.stream,
              //initialData: widget.children,
              builder: (_, snapshot) {
                if (snapshot.hasData && widget.children.last.hashCode != snapshot.data.hashCode) {
                  widget.children.add(snapshot.data);
                  
                }
                return ListView.builder(
                    controller: scrollControler,
                    itemCount: widget.children.length,
                    itemBuilder: (_, index) {
                      
                      if (index == widget.children.length - 1) {
                        Future.delayed(Duration(milliseconds: 200), () {
                          scrollControler
                            ..animateTo(
                              scrollControler.position.maxScrollExtent,
                              curve: Curves.easeOut,
                              duration: const Duration(milliseconds: 300),
                            );
                        });
                      }
                      return (widget.children[index]);
                    },
                    reverse: widget.reverseBodyList ?? false,
                    padding: EdgeInsets.all(0.0));
              },
            ),
          )),
          widget.footer ?? Container(),
        ],
      );
    }
  }
}

class GlowRemoveScrollBehaviour extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

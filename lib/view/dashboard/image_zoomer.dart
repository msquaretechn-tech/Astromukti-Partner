import 'package:flutter/material.dart';

class MyZoomImageWidget extends StatefulWidget {
  const MyZoomImageWidget({super.key, required this.imgUrl});

  final String imgUrl;

  @override
  State<MyZoomImageWidget> createState() => _MyZoomImageWidgetState();
}

class _MyZoomImageWidgetState extends State<MyZoomImageWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                contentPadding: EdgeInsets.zero,
                content: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyInteractiveViewer(
                                imgUrl: widget.imgUrl,
                              )));
                    },
                    child: Image.network(widget.imgUrl)),
              );
            });
      },
      child: Image.network(
        widget.imgUrl,
      ),
    );
  }
}

class MyInteractiveViewer extends StatelessWidget {
  const MyInteractiveViewer({super.key, required this.imgUrl});

  final String imgUrl;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(child: Image.network(imgUrl));
  }
}

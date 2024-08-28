import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pos_riverpod/screens/upload_image_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl:
                  'https://img.freepik.com/free-vector/white-abstract-background-3d-paper-style_23-2148402758.jpg?t=st=1724230263~exp=1724233863~hmac=eead3e8e4176bfcb59b2df4eb50ac36a175f8e2fcf789ef2ed2ee2d092887ab9&w=1380',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedButton(
                  icon: Icons.image_sharp,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                AnimatedButton(
                  icon: Icons.upload,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UploadImageScreen()),
                    );
                  },
                  showPuzzle: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool showPuzzle;

  const AnimatedButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.showPuzzle = false,
  }) : super(key: key);

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _colorAnimation = ColorTween(begin: Colors.grey.shade800, end: Colors.blue.shade300).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  Future<void> _showPuzzleDialog() async {
    final TextEditingController _puzzleController = TextEditingController();
    bool _isCorrect = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _puzzleController,
                decoration: const InputDecoration(
                  labelText: 'Enter 4 Digit code',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                if (_puzzleController.text == '1693') {
                  _isCorrect = true;
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((_) {
      if (_isCorrect) {
        widget.onPressed();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: () {
          _controller.forward().then((_) {
            if (widget.showPuzzle) {
              _showPuzzleDialog();
            } else {
              widget.onPressed();
              _controller.reverse();
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 4,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: 36.0,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

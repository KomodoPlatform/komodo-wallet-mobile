import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/model/swap_provider.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' as math;

class ProgressSwap extends StatefulWidget {
  const ProgressSwap({this.uuid, this.onFinished});

  final String uuid;
  final Function onFinished;

  @override
  _ProgressSwapState createState() => _ProgressSwapState();
}

class _ProgressSwapState extends State<ProgressSwap>
    with SingleTickerProviderStateMixin {
  AnimationController _radialProgressAnimationController;
  Animation<double> _progressAnimation;
  final Duration fadeInDuration = const Duration(milliseconds: 500);
  final Duration fillDuration = const Duration(seconds: 1);

  double progressDegrees = 0;
  int count = 0;
  Swap prevSwap = Swap();
  Swap swap;

  @override
  void initState() {
    super.initState();
    _radialProgressAnimationController =
        AnimationController(vsync: this, duration: fillDuration);
    _animateTo(0.0);
  }

  void _animateTo(double end) {
    _progressAnimation = null;
    _radialProgressAnimationController.reset();
    _progressAnimation = Tween<double>(begin: progressDegrees, end: end)
        .animate(CurvedAnimation(
            parent: _radialProgressAnimationController, curve: Curves.easeIn))
          ..addListener(() {
            setState(() {
              progressDegrees = _progressAnimation?.value ?? progressDegrees;
              if (progressDegrees == 360) {
                widget.onFinished();
              }
            });
          });

    _radialProgressAnimationController.forward();
  }

  @override
  void dispose() {
    _radialProgressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SwapProvider _swapProvider = Provider.of<SwapProvider>(context);
    swap = _swapProvider.swap(widget.uuid) ?? Swap();

    if (swap.step != prevSwap.step) {
      prevSwap = swap;
      _animateTo((360 / swap.steps) * swap.step);
    }

    final double heightScreen = MediaQuery.of(context).size.height * 0.06;
    double widthScreen = MediaQuery.of(context).size.width * 0.6;

    if (widthScreen > 250) {
      widthScreen = 250;
    }
    return Container(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            height: 16,
          ),
          Container(
            height: heightScreen,
            width: widthScreen,
            child: CustomPaint(
              painter: RadialPainter(
                  context: context, progressInDegrees: progressDegrees),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '${AppLocalizations.of(context).step} ',
                      style: Theme.of(context).textTheme.subtitle,
                    ),
                    Text(
                      swap.step.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .subtitle
                          .copyWith(color: Theme.of(context).accentColor),
                    ),
                    swap.step != 0
                        ? Text('/${swap.steps}',
                            style: Theme.of(context).textTheme.subtitle)
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
          Text(
            swapHistoryBloc.getSwapStatusString(context, swap.status),
            style: Theme.of(context).textTheme.body1.copyWith(
                fontWeight: FontWeight.w300,
                color: Colors.white.withOpacity(0.5)),
          )
        ],
      ),
    );
  }
}

class RadialPainter extends CustomPainter {
  const RadialPainter({@required this.context, this.progressInDegrees});

  final double progressInDegrees;
  final BuildContext context;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color.fromARGB(255, 52, 62, 76)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30.0;

    final Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width / 2, paint);

    final Paint progressPaint = Paint()
      ..shader = LinearGradient(colors: <Color>[
        const Color.fromARGB(255, 40, 80, 114),
        Theme.of(context).accentColor
      ]).createShader(Rect.fromCircle(center: center, radius: size.width / 2))
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30.0;

    canvas.drawArc(
        Rect.fromCircle(center: center, radius: size.width / 2),
        math.radians(-90),
        math.radians(progressInDegrees),
        false,
        progressPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

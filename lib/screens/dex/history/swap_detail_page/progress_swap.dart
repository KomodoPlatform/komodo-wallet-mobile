
import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/swap_history_bloc.dart';
import 'package:komodo_dex/localizations.dart';
import 'package:komodo_dex/model/swap.dart';
import 'package:komodo_dex/model/swap_provider.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' as math;

class ProgressSwap extends StatefulWidget {
  const ProgressSwap({this.swap, this.onStepFinish});

  final Swap swap;
  final Function onStepFinish;

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
  Swap swapTmp = Swap();

  @override
  void initState() {
    super.initState();
    swapTmp = widget.swap;
    _radialProgressAnimationController =
        AnimationController(vsync: this, duration: fillDuration);
    _initAnimation(0.0);
  }

  void _initAnimation(double begin) {
    _progressAnimation = null;
    _progressAnimation = Tween<double>(begin: begin, end: 360.0).animate(
        CurvedAnimation(
            parent: _radialProgressAnimationController, curve: Curves.easeIn))
      ..addListener(() {
        setState(() {
          final Swap swap = widget.swap;
          progressDegrees = (swap.step / swap.steps) * _progressAnimation.value;
          if (progressDegrees == 360) {
            widget.onStepFinish();
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

  int tmpStep = -1;

  @override
  Widget build(BuildContext context) {
    final SwapProvider _swapProvider = Provider.of<SwapProvider>(context);
    final Swap _swap = _swapProvider.swap(widget.swap.result.uuid);
    final steps = _swap.steps;
    final step = _swap.step;

    if (swapTmp.status != _swap.status || tmpStep != step) {
      swapTmp = _swap;
      tmpStep = step;
      _radialProgressAnimationController.value = 0;
      _radialProgressAnimationController.reset();
      if (steps == step) {
        _initAnimation(((360 / steps) * step) - (360 / steps));
      } else {
        _initAnimation((360 / steps) * step);
      }
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
                      _swap.step.toString(),
                      style: Theme.of(context)
                          .textTheme
                          .subtitle
                          .copyWith(color: Theme.of(context).accentColor),
                    ),
                    Text('/${_swap.steps}',
                        style: Theme.of(context).textTheme.subtitle)
                  ],
                ),
              ),
            ),
          ),
          Text(
            swapHistoryBloc.getSwapStatusString(context, _swap.status),
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

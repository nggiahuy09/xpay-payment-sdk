import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final class CapturePageRecorder<T> {
  T? result;
  bool isPopped = false;
}

Future<CapturePageRecorder<T>> pushCapturePage<T>(WidgetTester tester, Widget page) async {
  tester.view.physicalSize = const Size(1170.0, 2532.0);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);

  final recorder = CapturePageRecorder<T>();
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            recorder.result = await Navigator.of(context).push(MaterialPageRoute<T>(builder: (_) => page));
            recorder.isPopped = true;
          },
          child: const Text('open'),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  return recorder;
}

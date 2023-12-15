part of 'package:loc_poster/ui/home/ui/home_page.dart';

mixin MainMixin on State<HomePage> {
  late StreamSubscription<Position> positionStream;
  // late ProfileRepository profileRepository = sl();
  late Points point = Points(longitude: 0, latitude: 0);
  // late NetworkInfo networkInfo = awaut Connectivity().checkConnectivity();
  late List<TrackingModel> trackingList = [];
  late Battery battery = Battery();
  late AppLifecycleState lifeCycleState = AppLifecycleState.resumed;
  late Timer _timer;
  // late MainBloc bloc;

  Future<void> initController(WidgetsBindingObserver observer) async {
    // bloc = context.read<MainBloc>();
    await LocationMixin.instance.hasPermission().then(
      (value) async {
        if (value) {
          point = await LocationMixin.instance.determinePosition();
        } else {
          await Geolocator.openAppSettings();
        }
      },
    );
    WidgetsBinding.instance.addObserver(observer);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (!mounted) return;
    SharedPreferences instance = await SharedPreferences.getInstance();
    // bloc = context.read<MainBloc>();
    startAndStop(v: true, duration: instance.getInt('duration') ?? 5);
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        lifeCycleState = AppLifecycleState.resumed;
      case AppLifecycleState.inactive:
        lifeCycleState = AppLifecycleState.paused;
      case AppLifecycleState.paused:
        lifeCycleState = AppLifecycleState.paused;
      case AppLifecycleState.detached:
        lifeCycleState = AppLifecycleState.detached;
        positionStream.cancel();
      case AppLifecycleState.hidden:
        lifeCycleState = AppLifecycleState.hidden;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this as WidgetsBindingObserver);
    // NewOrderWebSocketService.instance.close();
    positionStream
      ..pause()
      ..cancel();
    _timer.cancel();
    super.dispose();
  }

  void startAndStop({bool v = false, int duration = 5}) {
    if (v) {
      bool isLocationEnabled = false;
      _timer = Timer.periodic(
        Duration(minutes: duration),
        (timer) async {
          if (lifeCycleState == AppLifecycleState.resumed) {
            if (await LocationMixin.instance.hasPermission()) {
              await streamLocation();

              // postWithDataAndHeaders();
              // if (localSource.hasProfile && await networkInfo.isConnected) {
              //
              //   // bloc.add(
              //   //     // SetUserPositionEvent(
              //   //     //   point: await Geolocator.getCurrentPosition(),
              //   //     // ),
              //   //     );
              // }
            } else {
              if (isLocationEnabled) return;
              isLocationEnabled = true;
              await LocationMixin.instance.isRequestService().then(
                (value) {
                  if (value) {
                    isLocationEnabled = false;
                    return;
                  } else {
                    Geolocator.openLocationSettings().then((value) {
                      isLocationEnabled = false;
                    });
                  }
                },
              );
            }
          }
        },
      );
      foregroundNotificationConfig();
    } else {
      _timer.cancel();
      positionStream.cancel();
    }
  }

  void foregroundNotificationConfig() {
    late LocationSettings locationSettings;
    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        useMSLAltitude: true,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 5),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          enableWakeLock: true,
          notificationText: "DevCraft ishlamoqda...",
          notificationTitle: 'Mazil ulashilmoqda...',
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
    }
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (position) async {
        if (lifeCycleState == AppLifecycleState.paused) {
          // if (localSource.hasProfile && await networkInfo.isConnected) {}
        }
      },
    );
  }

  Future<void> streamLocation() async {
    final int batteryPercent = await battery.batteryLevel;
    final Position position = await Geolocator.getCurrentPosition();
    SharedPreferences instance = await SharedPreferences.getInstance();
    String id = instance.getString('id') ?? '0';
    String name = instance.getString('login') ?? '';
    String surname = instance.getString('password') ?? '';
    String url = instance.getString('url') ?? '';
    String connection = await getConnectionType();

    setState(() {});
    trackingList.add(TrackingModel(
      network: connection.toString(),
      battery: batteryPercent,
      id: int.parse(id),
      lat: position.latitude,
      long: position.longitude,
    ));
    // final result = await profileRepository.addLastSeen(
    //   request: TrackingRequest(
    //     trackings: [
    //       TrackingModel(
    //         batteryPercent: batteryPercent,
    //         courierId: localSource.courierId,
    //         createdAt:
    //         ((position.timestamp?.millisecondsSinceEpoch ?? 0) / 1000)
    //             .truncate()
    //             .toString(),
    //         location: TrackingLocation(
    //           lat: position.latitude,
    //           long: position.longitude,
    //         ),
    //       ),
    //     ],
    //   ),
    // );
    // if (result is MessageResponse) {}
    postWithDataAndHeaders();
  }

// void listener(BuildContext context, HomeState state) {
//   if (state.isWorHourEnd) {
//     showDialog<void>(
//       barrierDismissible: false,
//       context: context,
//       builder: (context) => WillPopScope(
//         onWillPop: () async => false,
//         child: Dialog(
//           backgroundColor: Colors.white,
//           insetPadding: const EdgeInsets.all(16),
//           child: Padding(
//             padding: AppUtils.kPaddingAll16,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Text(
//                   'Ваше рабочее время закончилось',
//                 ),
//                 const SizedBox(height: 12),
//                 ElevatedButton(
//                   onPressed: () async {
//                     // _isCourierShiftStarted = !_isCourierShiftStarted;
//                     // Get.find<HomeController>()
//                     //     .setIsCourierShiftStartedValue(
//                     //         v: _isCourierShiftStarted);
//                     Navigator.pop(context);
//                   },
//                   child: const Center(
//                     child: Text(
//                       'Ok',
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
}

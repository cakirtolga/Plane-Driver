class Vehicle {
  const Vehicle({
    required this.id,
    required this.turnSpeed,
    required this.acceleration,
    required this.productId,
    this.isFree = false,
  });

  final int id;
  final double turnSpeed;
  final double acceleration;
  final String productId;
  final bool isFree;

  static const List<Vehicle> all = [
    Vehicle(id: 0, turnSpeed: 3, acceleration: 1, productId: 'com.tardagames.planedriver.plane_0', isFree: true),
    Vehicle(id: 1, turnSpeed: 4, acceleration: 1, productId: 'com.tardagames.planedriver.plane_1'),
    Vehicle(id: 2, turnSpeed: 5, acceleration: 2, productId: 'com.tardagames.planedriver.plane_2'),
    Vehicle(id: 3, turnSpeed: 8, acceleration: 0.01, productId: 'com.tardagames.planedriver.plane_3'),
    Vehicle(id: 4, turnSpeed: 2, acceleration: 4, productId: 'com.tardagames.planedriver.plane_4'),
    Vehicle(id: 5, turnSpeed: 1, acceleration: 1, productId: 'com.tardagames.planedriver.plane_5'),
  ];

  static Vehicle byId(int id) => all.firstWhere((v) => v.id == id);

  /// Gameplay tuning is intentionally independent from the final sprite art.
  /// Replacing an aircraft image later therefore cannot silently change its
  /// control feel.
  AircraftHandling get handling => AircraftHandling.forVehicle(id);
}

class AircraftHandling {
  const AircraftHandling({
    required this.maxForwardSpeed,
    required this.maxReverseSpeed,
    required this.driveResponse,
    required this.coastFriction,
    required this.turnRateDegrees,
  });

  final double maxForwardSpeed;
  final double maxReverseSpeed;
  final double driveResponse;
  final double coastFriction;
  final double turnRateDegrees;

  static AircraftHandling forVehicle(int id) {
    const profiles = <AircraftHandling>[
      AircraftHandling(maxForwardSpeed: 330, maxReverseSpeed: 125, driveResponse: 600, coastFriction: 1080, turnRateDegrees: 120),
      AircraftHandling(maxForwardSpeed: 350, maxReverseSpeed: 130, driveResponse: 630, coastFriction: 1100, turnRateDegrees: 128),
      AircraftHandling(maxForwardSpeed: 370, maxReverseSpeed: 135, driveResponse: 660, coastFriction: 1120, turnRateDegrees: 136),
      AircraftHandling(maxForwardSpeed: 345, maxReverseSpeed: 120, driveResponse: 570, coastFriction: 1040, turnRateDegrees: 112),
      AircraftHandling(maxForwardSpeed: 390, maxReverseSpeed: 125, driveResponse: 720, coastFriction: 1180, turnRateDegrees: 124),
      AircraftHandling(maxForwardSpeed: 310, maxReverseSpeed: 110, driveResponse: 540, coastFriction: 1010, turnRateDegrees: 102),
    ];
    return profiles[id.clamp(0, profiles.length - 1).toInt()];
  }
}

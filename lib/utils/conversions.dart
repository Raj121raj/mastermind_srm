import 'dart:math';

class Conversions {
  // dBm to Watts
  static String dbmToWatts(String dbm) {
    if (dbm.isEmpty) return '';
    try {
      double dbmValue = double.parse(dbm);
      double watts = pow(10, (dbmValue - 30) / 10).toDouble();
      return '${watts.toStringAsFixed(6)} W';
    } catch (e) {
      return 'Invalid input';
    }
  }

  // Watts to dBm
  static String wattsToDbm(String watts) {
    if (watts.isEmpty) return '';
    try {
      double wattsValue = double.parse(watts);
      if (wattsValue <= 0) return 'Invalid input (must be > 0)';
      double dbm = 10 * log(wattsValue * 1000) / ln10;
      return '${dbm.toStringAsFixed(2)} dBm';
    } catch (e) {
      return 'Invalid input';
    }
  }

  // Frequency to Wavelength
  static String freqToWavelength(String freq) {
    if (freq.isEmpty) return '';
    try {
      double freqValue = double.parse(freq);
      if (freqValue <= 0) return 'Invalid input (must be > 0)';
      const double speedOfLight = 299792458;
      double wavelength = speedOfLight / freqValue;
      return '${wavelength.toStringAsFixed(6)} m';
    } catch (e) {
      return 'Invalid input';
    }
  }

  // Wavelength to Frequency
  static String wavelengthToFreq(String wavelength) {
    if (wavelength.isEmpty) return '';
    try {
      double wavelengthValue = double.parse(wavelength);
      if (wavelengthValue <= 0) return 'Invalid input (must be > 0)';
      const double speedOfLight = 299792458;
      double freq = speedOfLight / wavelengthValue;
      return '${freq.toStringAsFixed(2)} Hz';
    } catch (e) {
      return 'Invalid input';
    }
  }

  // Rectangular to Polar
  static String rectToPolar(String real, String imag) {
    if (real.isEmpty || imag.isEmpty) return '';
    try {
      double x = double.parse(real);
      double y = double.parse(imag);
      double magnitude = sqrt(x * x + y * y);
      double angleRad = atan2(y, x); // Angle in radians
      double angleDeg = angleRad * 180 / pi; // Convert to degrees
      return 'Magnitude: ${magnitude.toStringAsFixed(6)}, Angle: ${angleDeg.toStringAsFixed(2)}°';
    } catch (e) {
      return 'Invalid input';
    }
  }

  // Polar to Rectangular
  static String polarToRect(String magnitude, String angle) {
    if (magnitude.isEmpty || angle.isEmpty) return '';
    try {
      double r = double.parse(magnitude);
      double thetaDeg = double.parse(angle);
      double thetaRad = thetaDeg * pi / 180; // Convert degrees to radians
      if (r < 0) return 'Invalid input (magnitude must be >= 0)';
      double x = r * cos(thetaRad);
      double y = r * sin(thetaRad);
      return 'Real: ${x.toStringAsFixed(6)}, Imag: ${y.toStringAsFixed(6)}';
    } catch (e) {
      return 'Invalid input';
    }
  }
}

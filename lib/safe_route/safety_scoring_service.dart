import 'package:google_maps_flutter/google_maps_flutter.dart';

class SafetyScoringService {
  int calculateScore(List<LatLng> points) {
    int score = 0;

    score += _streetLightScore(points);
    score += _crowdScore(points);
    score -= _riskyAreaPenalty(points);

    return score;
  }

  int _streetLightScore(List<LatLng> points) {
    return 10;  
  }

  int _crowdScore(List<LatLng> points) {
    return 5; 
  }

  int _riskyAreaPenalty(List<LatLng> points) {
    return 3;  
  }
}

/// Epley estimated one-rep max. A 1-rep set is already its own max.
double estimate1Rm(double weight, int reps) =>
    reps <= 1 ? weight : weight * (1 + reps / 30.0);

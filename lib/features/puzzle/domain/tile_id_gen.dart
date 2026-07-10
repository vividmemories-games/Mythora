/// Monotonic tile IDs for animation tracking across gravity / spawn.
class TileIdGen {
  TileIdGen([this._next = 1]);

  int _next;

  int next() => _next++;

  int get peek => _next;
}

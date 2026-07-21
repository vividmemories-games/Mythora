import '../../features/puzzle/domain/board_cell.dart';
import '../../features/puzzle/domain/tile_color.dart';

/// Central asset paths for presentation wiring.
abstract final class GameAssets {
  static const homeBackground = 'assets/images/backgrounds/bg_home_dusk.png';
  static const battleTwilightRoad =
      'assets/images/backgrounds/battle/bg_battle_twilight_road.png';
  static const mapTwilightRoad = 'assets/images/maps/map_ch_twilight_road.png';

  static const fxMatchClear = 'assets/images/vfx/fx_match_clear.png';
  static const fxSpecialCreate = 'assets/images/vfx/fx_special_create.png';
  static const fxHit = 'assets/images/vfx/fx_hit.png';
  static const fxBossFlee = 'assets/images/vfx/fx_boss_flee.png';

  static const prepVanguard = 'assets/images/prep/prep_vanguard_tonic.png';
  static const prepAegis = 'assets/images/prep/prep_aegis_flask.png';
  static const prepSecondWind = 'assets/images/prep/prep_second_wind.png';

  static const prepIcons = [prepVanguard, prepAegis, prepSecondWind];

  static const iconMoves = 'assets/images/icons/icon_moves.png';
  static const iconAp = 'assets/images/icons/icon_ap.png';

  /// Resource HUD reuses board gem art so colors stay consistent.
  static String resourceIcon(String resourceId) => switch (resourceId) {
        'attack' => tile(TileColor.red),
        'mana' => tile(TileColor.blue),
        'healing' => tile(TileColor.green),
        'shield' => tile(TileColor.yellow),
        'ultimate' => tile(TileColor.purple),
        _ => tile(TileColor.red),
      };

  static String hero(String heroId) => 'assets/heroes/hero_$heroId.png';

  static String tile(TileColor color) => switch (color) {
        TileColor.red => 'assets/images/tiles/tile_red.png',
        TileColor.blue => 'assets/images/tiles/tile_blue.png',
        TileColor.green => 'assets/images/tiles/tile_green.png',
        TileColor.yellow => 'assets/images/tiles/tile_yellow.png',
        TileColor.purple => 'assets/images/tiles/tile_purple.png',
      };

  static String? powerup(TileSpecial special) => switch (special) {
        TileSpecial.rocketVertical =>
          'assets/images/powerups/powerup_rocket_v.png',
        TileSpecial.rocketHorizontal =>
          'assets/images/powerups/powerup_rocket_h.png',
        TileSpecial.bomb => 'assets/images/powerups/powerup_bomb.png',
        TileSpecial.fireball => 'assets/images/powerups/powerup_fireball.png',
        TileSpecial.seeker => 'assets/images/powerups/powerup_seeker.png',
        TileSpecial.none => null,
      };

  /// Resolves enemy / boss sprite path. Boss forms use f4 finale art for now.
  static String enemy(String enemyId) => switch (enemyId) {
        'warchief' => 'assets/enemies/bosses/boss_warchief_ruk_f4.png',
        _ => 'assets/enemies/enemy_$enemyId.png',
      };
}

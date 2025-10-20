# Changelog

All notable changes to this project will be documented in this file.

## [1.2.0] - 2024-01-XX

### ✨ Added
- **Advanced Health Recovery System** with smart combat detection
- **Combat Detection System** that automatically pauses regeneration during combat
- **Damage Cooldown System** - 45-second cooldown after taking damage
- **Combat Timeout System** - 15 seconds of no damage to exit combat state
- **Improved Resting System** with more precise speed threshold
- **Debug Commands**:
  - `/healthstatus` - Shows current health regeneration status
  - `/healthdebug` - Toggles debug mode for health system
- **Integration Support**:
  - rex_zombies infection system integration
  - rsg-medic system integration
- **Enhanced Configuration** with detailed combat detection settings

### 🔧 Changed
- **Health Recovery Rate**: Reduced from 0.5% to 0.15% per cycle (70% slower)
- **Recovery Interval**: Increased from 10 seconds to 20 seconds (2x slower)
- **Maximum Recovery**: Reduced from 80% to 65% of max health
- **Resting Multiplier**: Reduced from 2.0x to 1.3x (35% less bonus)
- **Minimum Health Threshold**: Increased from 20% to 25%
- **Resting Speed Threshold**: More precise detection (0.8 instead of 1.0)

### 🐛 Fixed
- Health regeneration no longer occurs during combat
- Fixed unrealistic regeneration rates that made combat too easy
- Improved system balance for more realistic gameplay

### 📊 Performance
- **Overall Regeneration**: 85% reduction in regeneration speed
- **Combat Balance**: 100% pause during combat situations
- **Realistic Recovery**: More balanced and immersive health system

## [1.1.1] - Previous Version
- Basic health recovery system
- Alcohol effects and poison system
- Food and drink consumption mechanics
- Animation and prop system

---

## Migration Guide

### For Server Owners
1. **Backup your current config.lua** before updating
2. **Review new configuration options** in the updated config.lua
3. **Test the new system** with `/healthdebug` and `/healthstatus` commands
4. **Adjust settings** if needed for your server's balance

### Configuration Changes
The new system adds these configuration options:
```lua
CombatDetection = {
    Enabled = true,
    DamageCooldown = 45000,
    CombatTimeout = 15000,
    MinDamageToTrigger = 8,
}
```

### Breaking Changes
- Health regeneration is now significantly slower and more realistic
- Combat detection may affect players who were used to fast regeneration
- Some configuration values have changed (see "Changed" section above)

---

## Support
For issues or questions about the new health recovery system, please:
1. Check the debug output with `/healthdebug`
2. Use `/healthstatus` to verify system state
3. Review the configuration options in config.lua
4. Create an issue on GitHub with debug information

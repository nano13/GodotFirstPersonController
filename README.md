# Godot 4 - Basic First Person Controller
This project contains the basic implementation of a First Person character controller for [Godot 4](https://downloads.tuxfamily.org/godotengine/4.0/).

The code found in [player.gd](Player/player.gd) uses vector forces to move the player. You can tweak the values of the forces in the editor directly. The _velocity_ of the player is calculated as a result of the vector sum of different vector forces: walk, jump and gravity.

The main scene is a _Sandbox_ scene used to test the controls:

![EditorView](Assets/BasicFPCBeta17.png)

## Controls
| Keys | Action Name | Description |
|:------:|:-------------:|:-------------:|
| <kbd>W</kbd>,<kbd>A</kbd>,<kbd>S</kbd>,<kbd>D</kbd>, <kbd>left stick</kbd> | `move_` + _dir_ | Move |
| `mouse`, <kbd>right stick</kbd> | `look_` + _dir_ | Look/Aim |
| <kbd>Space</kbd>, <kbd>Xbox Ⓐ</kbd> | `jump` | On Land or Water Surface: Apply jump force; In Water: Swim Down; In Air: Press a second time to hold yourself in the air.|
| <kbd>Q</kbd>, <kbd></kbd> | `jump high` | Apply alternative, higher jump force (stackable to fly up high). |
| <kbd>F</kbd>, <kbd></kbd> | `flashlight` | Toggle Flashlight |
| <kbd>Ctrl</kbd>, <kbd></kbd> | `crouch` | On Land: Crouch; In Water: Swim Down |
| <kbd>Shift</kbd>, <kbd></kbd> | `walk` | Slower Walking Speed |
| <kbd>ESC</kbd>, <kbd>Xbox Ⓑ</kbd> | `exit` | Close the game |

You can change any of this keys in: Project Settings → Input Map.

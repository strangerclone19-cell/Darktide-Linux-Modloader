# Darktide-Linux-Modloader
Darktide modloader that works with linux

> ℹ️ **Quick Start / Important Instructions**
>
> 1. Extract the mod loader files into your game folder and overwrite existing
> 2. Change file permission if you get permission failed error
> 3. Run the provided script with `sh /path/to/<game_folder>/handle_darktide_mods.sh`
> 4. If the patch was successful, install the Darktide Mod Framework as normal
> 5. Then download Darktide Mod Framework [https://www.nexusmods.com/warhammer40kdarktide/mods/8]
> 6. Extract the file and put the "dmf" folder into the Mods folder in /home/username/.steam/steam/steamapps/common/Warhammer 40,000 DARKTIDE/mods
> 7. That is all you need to do after that you can just download any mods you want and then add the mod folder name to the modloader and run the game.
> https://www.nexusmods.com/warhammer40kdarktide/mods/8

# How to Use launch_darktide.sh with Steam Launch Settings

> ℹ️ **Steam Launch Script Instructions**
>
> To launch Darktide with mods using Steam's launch settings:
>
> 1. Right-click on Warhammer 40,000: Darktide in your Steam library
> 2. Select **Properties**
> 3. Under the **General** tab, find the **Launch Options** field
> 4. Add the following launch command:
>    ```
>    "<game_folder_path>/launch_darktide.sh" && %command%
>    ```
>    Replace `<game_folder_path>` with the full path to your game folder. Example:
>    ```
>    "/home/username/.steam/steam/steamapps/common/Warhammer 40,000 DARKTIDE/launch_darktide.sh" && %command%
>    ```
> 5. Make sure the script has execute permissions:
>    ```
>    chmod +x /path/to/<game_folder>/launch_darktide.sh
>    ```
> 6. Save the settings and launch the game from Steam

# How to Install Mods

> ℹ️ **After Modloader Install Instructions**
>
> 1. Download your mods from nexusmods or any other source
> 2. Extract the mod into mod folder in your game directory
> 3. Add the name of the mod into `mod_load_order.txt`
> 4. Run your game and enjoy

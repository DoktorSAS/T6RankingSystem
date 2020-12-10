# T6 Ranking System Wiki

On this page you can find all the information about the project. In fact, it is possible to read 
a whole list of information that allows the project developers to recognise the operations carried 
out by other users.

### How the system will work?

The whole programme will be based on file logging operations. In fact, at certain times during the game, the user will 
be able to save and send new data to the IW4M plugin, which will manage this data and modify the user's level. As it is dedicated 
to server owners, they can modify the ranking system by deciding how much weight is given to each event in a .cfg file.
- IW4M Plugin
- GSC Mod files
- CFG files

### GSC Mod
The accumulated experience is collected in a variable generated for this eventuality
```
  self.pers["xp_ranking"] = self.pers["xp_ranking"] + xp;
```

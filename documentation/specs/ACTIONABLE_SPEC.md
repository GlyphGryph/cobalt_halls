ACTIONABLE? COMMANDABLE?
Various objects need to be able to respond to various commands from commanders in various ways. They need to pass any messages on to observers. The goal is for the actionableized models to be slimmed down, and for all command handling logic to be moved to this specific model, only calling appropriate object specific methods when necessary.

Will we want to include the account manager logic here?
How do we want to handle Commandable objects that interact with other objects, and how objects respond to actions from Commandable objects? Maybe outside of scope here if that needs to be anything special? Maybe a "targetable" logic chain?
Not all commanders should be able to send all commands even to commandable objects. For example, admins will be able to send commands to player characters that players can not, like bestowing boons.

This should handle ALL parsing and argument breakdowns, allowing for more specific calls on object-specific behaviours.

How do we handle actions that require *consent* from the target?
Currently characters and all other objects currently interact differently with rooms. Do we want to generalize this more? At the very least we need actions like "look" to cascade up to room level even when in nested inventory (but not passing through closed containers? Potentially confusing).
Generalizing means that we can have objects transition between types (creatures stored as statues, for example) with far less effort.

We will soon need "interruptables" as well.


Our current and confirmed future commands are:
Look - display details of target (default target: room) from the perspective of the commanded object.
Move - Move an object through a room connection
Turn - Change an object's facing, which is necessary for relative descriptions
Get - Move an object from one inventory (default: room) to own inventory
Drop - Move an object from own inventory to new inventory (default: room)
Describe - Change an objects description (default: self)
Label - Change (or at least append to) an objects name when you look at it
Say - Self speaks a phrase.
Use - Trigger an objects use response. May be passed a third object. This one is a complicated one! Can some objects have multiple uses? How do we determine them? How do we check if the first object is able to use the second object and whether it works with the third object? Specifically: Doors can be locked/unlocked, or opened/closed. Which one responds to Use?
Open / Close - Triggers an object to change a state that prevents certain actions or behaviours such as looking and passing through. Applies to doors and containers.
Lock / Unlock - Triggers whether an object responds to Open/Close.
Eat - 
Help - Lists currently available commands.
Summon - For testing and admin purposes. Pass a series of arguments describing a new object to create in this player's inventory.
Destroy - For testing and admin purpoes. Commands an object to destroy itself.
Give Consent - Some actions queue up a "consent request" to the target, which requires a character to respond with this action before it finishes executing. Example: "getting" another character to add them to own inventory?

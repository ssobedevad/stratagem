Super-compact backwards/forwards/sideways compatible save game generation system. Checkout the campaign folder for the size of a level :)

Using a simple but effective key-value address pairing and a set of enums you read in the first 16 bits to tell you the size of the address PackedByteArray which contains all of the address kvps,
and then the next 16 bits tells you the size of the data PackedByteArray (Probably can be removed as it is kinda redundant at this point but 16 bits to make it harder to fiddle with the game files easy win)

Then the kvps are loaded into an array that is traversed and if the enum is known then an action is taken at the address associated with it. 
e.g. Building_5b enum tells you that there is a building description in the five bytes following the address given and will load in a building as long as this enum is not removed.
This allows for automatic compatibility as just loading and immediately resaving a file will update it to the latest version

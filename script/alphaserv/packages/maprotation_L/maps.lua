module("modes", package.seeall)

maps = {
	["xenon"] = {crc = "3864afeb2ac9e9c7347634aca595901a4f134cbd151dbdc6"},
	["pitch_black"] = {crc = "0baccf7667d8e30595d5a27c59128d0bca106673aac779c4"},
	["desecration"] = {crc = "c5fe500637b5f2e2ebfb6c0bd539197163f75ac1e52c6d9e"},
	["konkuri-to"] = {crc = "2b5068a106a723c18da1468b6d066cb54e17a7eab0314eeb"},
	["douze"] = {crc = "5c1fdf44f58c0bdfb0832a729db17c7844d66f1cc533861e"},
	["hades"] = {crc = "bf6f5bbfd5a260248424db5ae94e26259654d63d1afa099d"},
	["neondevastation"] = {crc = "7ae68a2a1cb900d512a0b0cdaea97076493dbc6b9d9f750d"},
	["nevil_c"] = {crc = "e956e2baefbe67763256de5d0c779867160d4a41c9c5bbd2"},
	["orion"] = {crc = "48d9455a5c02f3f4b6ef0f943966f97ae135cee59d75f06b"},
	["infamy"] = {crc = "0de74df3060fabc7e48c04da9609fb82d998f2b4aecec4ef"},
	["metl2"] = {crc = "9b0e432fc0f6c7507091fb1057b2d447f5c7741cf79176b1"},
	["moonlite"] = {crc = "affc66f8a36a8ca2209b5beec90fc42d650c76b2c9ba886c"},
	["tejen"] = {crc = "b1c57403bfed6257406062c35062f22af215d0449f86bd76"},
	["castle_trap"] = {crc = "a87ee861a9ac2a3f070c93d0ab7e8cbbd42718430abf6b5c"},
	["osiris"] = {crc = "dae5801a04836a51591ab303d4deb8dde8c120024ad3d48b"},
	["duel8"] = {crc = "e459fa7a2f00fd642e1cc482e946332785e129535504c41b"},
	["face-capture"] = {crc = "126871fd0b7eb40716315f252c8c8d741a47ebd3c8531094"},
	["neonpanic"] = {crc = "f6004fd7cefa7850585e78d128515f62e90f3f3ea133ab07"},
	["ruine"] = {crc = "1df362b3ed9edb69fe8ec39260d172437ee650b21e9705d9"},
	["venice"] = {crc = "9285196ecbc9543341339439d6a71ef66ad4bf39d7ae8aac"},
	["valhalla"] = {crc = "4e2f22c883b4da41259e9d35d60c2bc4d74f5f7d15cd469d"},
	["pgdm"] = {crc = "8ec0c424c2c0d2045febc532b1ccb58ece895774ea45ee7f"},
	["academy"] = {crc = "7b38f9083ae155638daf5e84856fe0cef23bf31cd584966b"},
	["flagstone"] = {crc = "0ab64d97c8d9e62931d91f53affc69a7e4b570a8e955e317"},
	["hog2"] = {crc = "a2c4c65bf1c3ad7223fc0b29ed52bb2fe46bc4b9dd3e665d"},
	["cwcastle"] = {crc = "339c43116cb37b7889129b77741f3bcc9ff7415f45884fae"},
	["kmap5"] = {crc = "e2c2dda0c4f09c93baff95cea232c1ac1f6892587ccc3802"},
	["urban_c"] = {crc = "a51246c3ab334f3d6eb8d7583cd62338bd20e1bf4506f723"},
	["kalking1"] = {crc = "5520c5a8bde4b6f4094a10d874019c1b6c45ad6f7616cdce"},
	["lostinspace"] = {crc = "07d508752d721253a0b8be4c96539462c9ccc09a2a1b5f29"},
	["nitro"] = {crc = "c646c3518d8ac4e7c146d37f4e38e5fb5e5c717450483a4b"},
	["dust2"] = {crc = "ddac32c99809dc523192d874955c20bebed6381f4e9c60b6"},
	["curvedm"] = {crc = "9876a6459104210b5de9c1a398c7da996e22a1f5b60e8558"},
	["dock"] = {crc = "6c4a236b4f35b5a568091f16be574d706002973be9aa86c7"},
	["river_c"] = {crc = "53073aeea137cf172b547c766945828bb46685d6a09786d1"},
	["injustice"] = {crc = "3177652e23ae79a4c5facbee381ebfb714b5f47fd0b504b1"},
	["shadowed"] = {crc = "3f424eed79412488395b6ca3a10f26cf21bbacbb5f6634fc"},
	["mbt2"] = {crc = "34b8b9cb4784dd5786283302fac67b91294a66084b44055f"},
	["forge"] = {crc = "6280c3b13a0d3a3e3201ea879f85d28a97f7ee181313c2b5"},
	["c_valley"] = {crc = "ed342aa13239b90f0e9a4d7faa1ae7faf9bdd49cf709a467"},
	["asteroids"] = {crc = "206e93376b74c8b92425e79a155483c7c7d82e4ace16a4a5"},
	["torment"] = {crc = "46b2a21e8da57734c27ca8e9fccf9e1b083e67e4331f4d0e"},
	["paradigm"] = {crc = "8a1d3154c5e16d024f53b0e3f1ea154982e0f63d5402c1a0"},
	["shindou"] = {crc = "a81d47df6fcc27ccec5a45d89105e18da9898daef4caa0a9"},
	["suburb"] = {crc = "fe8ff63dbba3e453c4c552781a819b712f212acf179b65e0"},
	["reissen"] = {crc = "38b0b1522e93f4714465ce9e104db30e05143efd50e4b5da"},
	["thetowers"] = {crc = "64ef6a8a48877334589c4a7ad3d4584e0a6d244745372bf8"},
	["ogrosupply"] = {crc = "9f07361dde90ae9ea00237cbb52f98889c26d9d63db8f03e"},
	["curvy_castle"] = {crc = "5e371347d4fb8b7715378f71d8338272960c22aad162eb46"},
	["alloy"] = {crc = "1b46436bd659fbfc7dc333b3cbba57bb2a51776725c965c0"},
	["complex"] = {crc = "b83d644febb90994c90d47a233b9022909dde8a96afd953d"},
	["oddworld"] = {crc = "a4ade9748db056673682d710187a776aeeb1fb83ab7a6a1c"},
	["fragplaza"] = {crc = "6d687630bf96b1c38860ee6cbcd88f6237c3e75d70cdecc5"},
	["arabic"] = {crc = "5ee2bd9debe9de6e8eb0e81fbe04ca4940df500345afd3da"},
	["tempest"] = {crc = "9774b467a658bb013c76b8903ce69a9c755fec2b706f9f5a"},
	["l_ctf"] = {crc = "b29ef405fa4fba31dfad127e05a85864a5aee13bdbff826f"},
	["campo"] = {crc = "5ebbf52668b28dc4330c3c215272c931e5ac02c2c7ac0882"},
	["shinmei1"] = {crc = "f01e7a94ab2c88cc18f83f613a451d00cd6b883e2de7537f"},
	["kffa"] = {crc = "c8ca3cb9b0ad93b768bc2e360f187d2d96c3464cc4440c03"},
	["thor"] = {crc = "fefa44c7029c89d174e69e146c404d52bf52cf872e69d5d7"},
	["aard3c"] = {crc = "a2832d454169a43c00166af1fed300cc68334c968e8ca8ff"},
	["island"] = {crc = "7845589da9a27b13a53d6d82692a9c27a031743799f4b20f"},
	["turbine"] = {crc = "f3fc8fd0d984f263ffbffec806893b682689ce5d0b596d09"},
	["c_egypt"] = {crc = "d495245e393ec3a3822307e2ca5b380446f475766fb47d01"},
	["akaritori"] = {crc = "42bcc0e80b833c7a7e8e663a2bfad188e4fb767c89f1260f"},
	["corruption"] = {crc = "a716929123c8ad242a4135c3dc66e2fd03aad844f5358417"},
	["authentic"] = {crc = "91a168dc83fc726c405e28a0c7ad6cec96ebdaf587da395a"},
	["orbe"] = {crc = "e4675a5a824dd8488d5264b37b14ebd12611ac00542e6fee"},
	["deathtek"] = {crc = "5662cbe64a0cd74dab2358da3c0c869ff1b71d3db2450536"},
	["nmp8"] = {crc = "ad0587924348f55ce5a6aefaf43a29e32fa93ef50194c6a9"},
	["core_transfer"] = {crc = "9569e3164e9fd7c085a98da1c7035b8528bdd9df1fbb2deb"},
	["metl4"] = {crc = "1a38778ae6e67cad1a3e55f62e421c8fb5c655bcb89179d3"},
	["fc4"] = {crc = "c90b015120afbaee622e0c05f82377ba10de83e99334f695"},
	["mbt10"] = {crc = "bed11c962646b987927840e38301b9e9444ad48283ee0c6b"},
	["oasis"] = {crc = "362bde47e5621818fb0b6482ffd6c5351514cd7c2b144d81"},
	["frozen"] = {crc = "7798fdee9954f881fdac679b886f3a969471dbc196408b43"},
	["fc5"] = {crc = "c6d06dc08eb13f7576cf0c7913b3e92c769d38eec6775ab8"},
	["memento"] = {crc = "96bba69912d4f19adb0db63e3513319991d5328bad178c8e"},
	["fanatic_quake"] = {crc = "9840ecc1b3ecad0af659ce322e0f9e8a9faccd5e7eb1e45c"},
	["refuge"] = {crc = "5732ff1e27d7f85221d51b4ec6bd883710387c2e5114ef99"},
	["recovery"] = {crc = "45581e7079d6084d0cdfea0023063735c8edaddd7fe63ff5"},
	["berlin_wall"] = {crc = "ca41104bbae40aeb9d178a5949d6a0eab106629915b5cd6f"},
	["metl3"] = {crc = "85ca2ccc5a80788c563c8c8f9bee3ae4987a70cfc46853a4"},
	["wdcd"] = {crc = "a9b820caa9cb456651b69d9e003f23224e39563976210b84"},
	["sacrifice"] = {crc = "8ba05c97fdb2a74d3edeb068be2de56931b04f7c1ecb1b8b"},
	["phosgene"] = {crc = "ff0114c96739fd5d1f44671bcca5ef07f5ad026c797cef96"},
	["redemption"] = {crc = "cbfabd2ad9a94683e3311fe3ae4c881aa5770c9073961aa3"},
	["core_refuge"] = {crc = "fc9d3e620d648a3d3421c38179423d27584f287d1f29ec4e"},
	["damnation"] = {crc = "30d5c23a394398be9db5c00053cbe8c6452eccab6f2a847f"},
	["mercury"] = {crc = "629adc5916ca1f1dd454e02224718f55b59cf73e0ba3ca20"},
	["mbt1"] = {crc = "4fb602b75fd39b6f78179d463e58b280d9762e3e0afbefb8"},
	["bt_falls"] = {crc = "634b7b0f9bec8e80aad19a1572b2af4ff8387f1798a726df"},
	["capture_night"] = {crc = "30fd24c05ce9f453313693740085783bdbe1036aec3f5b78"},
	["duel7"] = {crc = "9be0248a073865d405886633eb58c9534826ecc5086ec65c"},
	["serenity"] = {crc = "5da565a53adb6a97d2221b08ee2acb37511228519d7ac196"},
	["shipwreck"] = {crc = "f84890e994396e0bda4a761ac32f4eeb3f680b154c4e08b5"},
	["fc3"] = {crc = "d295bcc6d921b2600118cc7eefffc3e4c525ae5dea206a61"},
	["europium"] = {crc = "0946b3822bad977d1309e6004157d6b577c75043f6486977"},
	["stemple"] = {crc = "c1e4f4ed2dad105449b1aaab5889875bf8acb89628fd8b0e"},
	["mach2"] = {crc = "ba0ad8ac6e026dca191140845b5761fcc487b4b375bae6b9"},
	["abbey"] = {crc = "cf4a80946a3d215ffe5a9b15fd2bc91fc9a8ca2ae839efcf"},
	["killcore3"] = {crc = "389bacfae1b56a4afd956ea0d0422e5dc406e14e00d9b8c4"},
	["caribbean"] = {crc = "0f2ed4afeec120cd7df71461040eb927584b78a583771a46"},
	["duomo"] = {crc = "36ad8b31eda1a9f2c44421b690423e571471f2805fa4e794"},
	["akroseum"] = {crc = "bada2da696e05441c2191e60e19549eb687104a946e2577a"},
	["DM_BS1"] = {crc = "e36b43e78e3947993a75123d2582f5d79de42f4cab7ac619"},
	["ph-capture"] = {crc = "4fa2c907747785f16947fbd47d2ed630b41660ccdda8f9fa"},
	["tartech"] = {crc = "e37314861548b276fce5c7b27c554d87fcbe644570795cd5"},
	["nmp4"] = {crc = "a73da0445eae019cd7a892e23a49e6835f83ba341b1edb41"},
	["ruby"] = {crc = "68cf1bc15a7904e4103dd8cb3a48b544f6189cede58e9a87"},
	["ot"] = {crc = "20b71fe430635c0809ef78403a1fca593e6ce9e44d9f366f"},
	["monastery"] = {crc = "3c7b24e11a28f580eb2f8c7a1661362b392af63ee5301f22"},
	["sdm1"] = {crc = "da2221c5cfc308c209434cbe6211268b44a07daf3374ddd2"},
	["hallo"] = {crc = "4a524402fec59b659b3f8dba347552ced074bbbe974f5c53"},
	["nmp9"] = {crc = "8061a03b8c70a1167366783492bfd3e76396b4f86f586f2e"},
	["fb_capture"] = {crc = "2370b5d54a19495371916d944c30f68f0a73d207edbfa3cd"},
	["darkdeath"] = {crc = "ee316ec90c768dcde58b79644d0341811dd0eacf208a922a"},
	["ksauer1"] = {crc = "8d17b9cdde4f71fff592c659988afd76513307ac24a7e898"},
	["tortuga"] = {crc = "911e9c3f2f3c9f3b51bdcb1fc4036774466a390cb7d4a05f"},
	["frostbyte"] = {crc = "ccf93c8abeb66e8c6a6206b1f8e91cb31e8c2d464c56a28a"},
	["guacamole"] = {crc = "92c3fb93eecb57ff67a195820106b5b2520ff1c9f031b664"},
	["katrez_d"] = {crc = "e433449a1e2f04d07523a40822db89959e32d1f8f22a2a57"},
	["aqueducts"] = {crc = "886f3a21b702c56d4ba1df4d73c9af58d22726f1dc9257c0"},
	["roughinery"] = {crc = "9aa07a248ac7bef7d9d832085671fe35a74b6009144b0b58"},
	["killfactory"] = {crc = "f1e289243a5cc7201815bc063c3f953e59c93d5c23f1a9ce"},
	["wake5"] = {crc = "f0b67b25e3a5d6407320419201bf63019c67405f9ad476b8"},
	["dune"] = {crc = "bc46b435f24d19751d3f800afc0f77a105416d147d942976"},
	["park"] = {crc = "8d8e407086e0251a9847e9c0b297e19ba7196bd7031fa878"},
	["powerplant"] = {crc = "03593fcb2bed248f514ba131a526e0c03e951b9f74a123e0"},
	["relic"] = {crc = "9d9fdb17ecf5c14ea2686612d37ce638d3b7273cb9233614"},
	["justice"] = {crc = "cfca0d17c2ff22c0e37d82bc966cd81f4a7d228cc3503907"},
	["industry"] = {crc = "a182d4598fc0857dd5c943825a50dd33352865437faca6bc"},
}

modes = {}

modes["insta ctf"] = { "suburb", "caribbean", "l_ctf", "frostbyte", "reissen", "tejen", "dust2", "akroseum", "shipwreck", "flagstone", "urban_c", "bt_falls", "valhalla", "mbt1", "berlin_wall", "authentic", "tempest", "mercury", "redemption", "damnation", "forge", "campo", "nitro", "core_refuge", "wdcd", "desecration", "sacrifice", "recovery", "infamy", "tortuga", "abbey", "xenon", "hallo", "capture_night", "face-capture", "mach2", "europium", "core_transfer", "killcore3", "konkuri-to", "fc5", "alloy", "duomo" }

modes["efficiency ctf"] = { "wdcd", "hallo", "flagstone", "tempest", "capture_night", "reissen", "shipwreck", "authentic", "urban_c", "bt_falls", "l_ctf", "face-capture", "valhalla", "mbt1", "mach2", "dust2", "berlin_wall", "mercury", "akroseum", "europium", "abbey", "redemption", "damnation", "forge", "campo", "nitro", "core_refuge", "xenon", "desecration", "sacrifice", "core_transfer", "recovery", "infamy", "tortuga" }

modes["ctf"] = { "wdcd", "hallo", "flagstone", "tempest", "capture_night", "reissen", "shipwreck", "authentic", "urban_c", "bt_falls", "l_ctf", "face-capture", "valhalla", "mbt1", "mach2", "dust2", "berlin_wall", "mercury", "akroseum", "europium", "abbey", "redemption", "damnation", "forge", "campo", "nitro", "core_refuge", "xenon", "desecration", "sacrifice", "core_transfer", "recovery", "infamy", "tortuga" }

modes["insta hold"] = { "wdcd", "hallo", "flagstone", "tempest", "capture_night", "reissen", "shipwreck", "authentic", "urban_c", "bt_falls", "l_ctf", "face-capture", "valhalla", "mbt1", "mach2", "dust2", "berlin_wall", "mercury", "akroseum", "europium", "abbey", "redemption", "damnation", "forge", "campo", "nitro", "core_refuge", "xenon", "desecration", "sacrifice", "core_transfer", "recovery", "infamy", "tortuga" }

modes["efficiency hold"] = { "wdcd", "hallo", "flagstone", "tempest", "capture_night", "reissen", "shipwreck", "authentic", "urban_c", "bt_falls", "l_ctf", "face-capture", "valhalla", "mbt1", "mach2", "dust2", "berlin_wall", "mercury", "akroseum", "europium", "abbey", "redemption", "damnation", "forge", "campo", "nitro", "core_refuge", "xenon", "desecration", "sacrifice", "core_transfer", "recovery", "infamy", "tortuga" }

modes["hold"] = { "wdcd", "hallo", "flagstone", "tempest", "capture_night", "reissen", "shipwreck", "authentic", "urban_c", "bt_falls", "l_ctf", "face-capture", "valhalla", "mbt1", "mach2", "dust2", "berlin_wall", "mercury", "akroseum", "europium", "abbey", "redemption", "damnation", "forge", "campo", "nitro", "core_refuge", "xenon", "desecration", "sacrifice", "core_transfer", "recovery", "infamy", "tortuga" }

modes["insta protect"] = { "wdcd", "hallo", "flagstone", "tempest", "capture_night", "reissen", "shipwreck", "authentic", "urban_c", "bt_falls", "l_ctf", "face-capture", "valhalla", "mbt1", "mach2", "dust2", "berlin_wall", "mercury", "akroseum", "europium", "abbey", "redemption", "damnation", "forge", "campo", "nitro", "core_refuge", "xenon", "desecration", "sacrifice", "core_transfer", "recovery", "infamy", "tortuga" }

modes["efficiency protect"] = { "wdcd", "hallo", "flagstone", "tempest", "capture_night", "reissen", "shipwreck", "authentic", "urban_c", "bt_falls", "l_ctf", "face-capture", "valhalla", "mbt1", "mach2", "dust2", "berlin_wall", "mercury", "akroseum", "europium", "abbey", "redemption", "damnation", "forge", "campo", "nitro", "core_refuge", "xenon", "desecration", "sacrifice", "core_transfer", "recovery", "infamy", "tortuga" }

modes["protect"] = { "wdcd", "hallo", "flagstone", "tempest", "capture_night", "reissen", "shipwreck", "authentic", "urban_c", "bt_falls", "l_ctf", "face-capture", "valhalla", "mbt1", "mach2", "dust2", "berlin_wall", "mercury", "akroseum", "europium", "abbey", "redemption", "damnation", "forge", "campo", "nitro", "core_refuge", "xenon", "desecration", "sacrifice", "core_transfer", "recovery", "infamy", "tortuga" }

modes["ffa"] = {"complex", "douze", "ot", "academy", "metl2", "metl3", "justice", "turbine", "mbt2", "fanatic_quake", "dock", "curvy_castle", "duel8", "nmp8", "tartech", "aard3c", "industry", "alloy", "ruine", "mbt10", "park", "refuge", "curvedm", "kalking1", "hog2", "kffa", "fragplazza", "pgdm", "neondevastation", "memento", "neonpanic", "sdm1", "island", "DMBS1", "shimney1", "osiris", "injustice", "powerplant", "phosgene", "oasis", "metl4", "ruby", "frozen", "dune", "wake5", "killfactory", "orbe", "roughinery", "shadowed", "tormet", "duel7", "pitch_black", "oddworld", "aqueducts", "akaritory", "konkuri-to", "moonlite", "castle_trap", "orion", "katrez_d", "thor", "frostbyte", "ogrosupply", "kmap5", "thetowers", "guacamole", "tejen", "suburb", "stemple", "ksauer1", "deathtek", "hades", "corruption", "paradigm", "lostinspace", "wdcd", "darkdeath", "wdcd", "hallo", "flagstone", "tempest", "capture_night", "reissen", "shipwreck", "authentic", "urban_c", "bt_falls", "l_ctf", "face-capture", "valhalla", "mbt1", "mach2", "dust2", "berlin_wall", "mercury", "akroseum", "europium", "abbey", "redemption", "damnation", "forge", "campo", "nitro", "core_refuge", "xenon", "desecration", "sacrifice", "core_transfer", "recovery", "infamy", "tortuga"}

modes["instagib"] = { "complex", "douze", "ot", "academy", "metl2", "metl3", "justice", "turbine", "mbt2", "fanatic_quake", "dock", "curvy_castle", "duel8", "nmp8", "tartech", "aard3c", "industry", "alloy", "ruine", "mbt10", "park", "refuge", "curvedm", "kalking1", "hog2", "kffa", "fragplazza", "pgdm", "neondevastation", "memento", "neonpanic", "sdm1", "island", "DMBS1", "shimney1", "osiris", "injustice", "powerplant", "phosgene", "oasis", "metl4", "ruby", "frozen", "dune", "wake5", "killfactory", "orbe", "roughinery", "shadowed", "tormet", "duel7", "pitch_black", "oddworld", "aqueducts", "akaritory", "konkuri-to", "moonlite", "castle_trap", "orion", "katrez_d", "thor", "frostbyte", "ogrosupply", "kmap5", "thetowers", "guacamole", "tejen", "suburb", "stemple", "ksauer1", "deathtek", "hades", "corruption", "paradigm", "lostinspace", "wdcd", "darkdeath", "wdcd", "hallo", "flagstone", "tempest", "capture_night", "reissen", "shipwreck", "authentic", "urban_c", "bt_falls", "l_ctf", "face-capture", "valhalla", "mbt1", "mach2", "dust2", "berlin_wall", "mercury", "akroseum", "europium", "abbey", "redemption", "damnation", "forge", "campo", "nitro", "core_refuge", "xenon", "desecration", "sacrifice", "core_transfer", "recovery", "infamy", "tortuga"}

modes["efficiency"] = { "complex", "douze", "ot", "academy", "metl2", "metl3", "justice", "turbine", "mbt2", "fanatic_quake", "dock", "curvy_castle", "duel8", "nmp8", "tartech", "aard3c", "industry", "alloy", "ruine", "mbt10", "park", "refuge", "curvedm", "kalking1", "hog2", "kffa", "fragplazza", "pgdm", "neondevastation", "memento", "neonpanic", "sdm1", "island", "DMBS1", "shimney1", "osiris", "injustice", "powerplant", "phosgene", "oasis", "metl4", "ruby", "frozen", "dune", "wake5", "killfactory", "orbe", "roughinery", "shadowed", "tormet", "duel7", "pitch_black", "oddworld", "aqueducts", "akaritory", "konkuri-to", "moonlite", "castle_trap", "orion", "katrez_d", "thor", "frostbyte", "ogrosupply", "kmap5", "thetowers", "guacamole", "tejen", "suburb", "stemple", "ksauer1", "deathtek", "hades", "corruption", "paradigm", "lostinspace", "wdcd", "darkdeath", "wdcd", "hallo", "flagstone", "tempest", "capture_night", "reissen", "shipwreck", "authentic", "urban_c", "bt_falls", "l_ctf", "face-capture", "valhalla", "mbt1", "mach2", "dust2", "berlin_wall", "mercury", "akroseum", "europium", "abbey", "redemption", "damnation", "forge", "campo", "nitro", "core_refuge", "xenon", "desecration", "sacrifice", "core_transfer", "recovery", "infamy", "tortuga"}

modes["tactics"] = { "complex", "douze", "ot", "academy", "metl2", "metl3", "justice", "turbine", "mbt2", "fanatic_quake", "dock", "curvy_castle", "duel8", "nmp8", "tartech", "aard3c", "industry", "alloy", "ruine", "mbt10", "park", "refuge", "curvedm", "kalking1", "hog2", "kffa", "fragplazza", "pgdm", "neondevastation", "memento", "neonpanic", "sdm1", "island", "DMBS1", "shimney1", "osiris", "injustice", "powerplant", "phosgene", "oasis", "metl4", "ruby", "frozen", "dune", "wake5", "killfactory", "orbe", "roughinery", "shadowed", "tormet", "duel7", "pitch_black", "oddworld", "aqueducts", "akaritory", "konkuri-to", "moonlite", "castle_trap", "orion", "katrez_d", "thor", "frostbyte", "ogrosupply", "kmap5", "thetowers", "guacamole", "tejen", "suburb", "stemple", "ksauer1", "deathtek", "hades", "corruption", "paradigm", "lostinspace", "wdcd", "darkdeath", "wdcd", "hallo", "flagstone", "tempest", "capture_night", "reissen", "shipwreck", "authentic", "urban_c", "bt_falls", "l_ctf", "face-capture", "valhalla", "mbt1", "mach2", "dust2", "berlin_wall", "mercury", "akroseum", "europium", "abbey", "redemption", "damnation", "forge", "campo", "nitro", "core_refuge", "xenon", "desecration", "sacrifice", "core_transfer", "recovery", "infamy", "tortuga"}

modes["efficiency team"] = { "complex", "douze", "ot", "academy", "metl2", "metl3", "justice", "turbine", "mbt2", "fanatic_quake", "dock", "curvy_castle", "duel8", "nmp8", "tartech", "aard3c", "industry", "alloy", "ruine", "mbt10", "park", "refuge", "curvedm", "kalking1", "hog2", "kffa", "fragplazza", "pgdm", "neondevastation", "memento", "neonpanic", "sdm1", "island", "DMBS1", "shimney1", "osiris", "injustice", "powerplant", "phosgene", "oasis", "metl4", "ruby", "frozen", "dune", "wake5", "killfactory", "orbe", "roughinery", "shadowed", "tormet", "duel7", "pitch_black", "oddworld", "aqueducts", "akaritory", "konkuri-to", "moonlite", "castle_trap", "orion", "katrez_d", "thor", "frostbyte", "ogrosupply", "kmap5", "thetowers", "guacamole", "tejen", "suburb", "stemple", "ksauer1", "deathtek", "hades", "corruption", "paradigm", "lostinspace", "wdcd", "darkdeath", "wdcd", "hallo", "flagstone", "tempest", "capture_night", "reissen", "shipwreck", "authentic", "urban_c", "bt_falls", "l_ctf", "face-capture", "valhalla", "mbt1", "mach2", "dust2", "berlin_wall", "mercury", "akroseum", "europium", "abbey", "redemption", "damnation", "forge", "campo", "nitro", "core_refuge", "xenon", "desecration", "sacrifice", "core_transfer", "recovery", "infamy", "tortuga"}

modes["instagib team"] = { "complex", "douze", "ot", "academy", "metl2", "metl3", "justice", "turbine", "mbt2", "fanatic_quake", "dock", "curvy_castle", "duel8", "nmp8", "tartech", "aard3c", "industry", "alloy", "ruine", "mbt10", "park", "refuge", "curvedm", "kalking1", "hog2", "kffa", "fragplazza", "pgdm", "neondevastation", "memento", "neonpanic", "sdm1", "island", "DMBS1", "shimney1", "osiris", "injustice", "powerplant", "phosgene", "oasis", "metl4", "ruby", "frozen", "dune", "wake5", "killfactory", "orbe", "roughinery", "shadowed", "tormet", "duel7", "pitch_black", "oddworld", "aqueducts", "akaritory", "konkuri-to", "moonlite", "castle_trap", "orion", "katrez_d", "thor", "frostbyte", "ogrosupply", "kmap5", "thetowers", "guacamole", "tejen", "suburb", "stemple", "ksauer1", "deathtek", "hades", "corruption", "paradigm", "lostinspace", "wdcd", "darkdeath", "wdcd", "hallo", "flagstone", "tempest", "capture_night", "reissen", "shipwreck", "authentic", "urban_c", "bt_falls", "l_ctf", "face-capture", "valhalla", "mbt1", "mach2", "dust2", "berlin_wall", "mercury", "akroseum", "europium", "abbey", "redemption", "damnation", "forge", "campo", "nitro", "core_refuge", "xenon", "desecration", "sacrifice", "core_transfer", "recovery", "infamy", "tortuga"}

modes["tactics team"] = { "complex", "douze", "ot", "academy", "metl2", "metl3", "justice", "turbine", "mbt2", "fanatic_quake", "dock", "curvy_castle", "duel8", "nmp8", "tartech", "aard3c", "industry", "alloy", "ruine", "mbt10", "park", "refuge", "curvedm", "kalking1", "hog2", "kffa", "fragplazza", "pgdm", "neondevastation", "memento", "neonpanic", "sdm1", "island", "DMBS1", "shimney1", "osiris", "injustice", "powerplant", "phosgene", "oasis", "metl4", "ruby", "frozen", "dune", "wake5", "killfactory", "orbe", "roughinery", "shadowed", "tormet", "duel7", "pitch_black", "oddworld", "aqueducts", "akaritory", "konkuri-to", "moonlite", "castle_trap", "orion", "katrez_d", "thor", "frostbyte", "ogrosupply", "kmap5", "thetowers", "guacamole", "tejen", "suburb", "stemple", "ksauer1", "deathtek", "hades", "corruption", "paradigm", "lostinspace", "wdcd", "darkdeath", "wdcd", "hallo", "flagstone", "tempest", "capture_night", "reissen", "shipwreck", "authentic", "urban_c", "bt_falls", "l_ctf", "face-capture", "valhalla", "mbt1", "mach2", "dust2", "berlin_wall", "mercury", "akroseum", "europium", "abbey", "redemption", "damnation", "forge", "campo", "nitro", "core_refuge", "xenon", "desecration", "sacrifice", "core_transfer", "recovery", "infamy", "tortuga"}

modes["teamplay"] = { "complex", "douze", "ot", "academy", "metl2", "metl3", "justice", "turbine", "mbt2", "fanatic_quake", "dock", "curvy_castle", "duel8", "nmp8", "tartech", "aard3c", "industry", "alloy", "ruine", "mbt10", "park", "refuge", "curvedm", "kalking1", "hog2", "kffa", "fragplazza", "pgdm", "neondevastation", "memento", "neonpanic", "sdm1", "island", "DMBS1", "shimney1", "osiris", "injustice", "powerplant", "phosgene", "oasis", "metl4", "ruby", "frozen", "dune", "wake5", "killfactory", "orbe", "roughinery", "shadowed", "tormet", "duel7", "pitch_black", "oddworld", "aqueducts", "akaritory", "konkuri-to", "moonlite", "castle_trap", "orion", "katrez_d", "thor", "frostbyte", "ogrosupply", "kmap5", "thetowers", "guacamole", "tejen", "suburb", "stemple", "ksauer1", "deathtek", "hades", "corruption", "paradigm", "lostinspace", "wdcd", "darkdeath", "wdcd", "hallo", "flagstone", "tempest", "capture_night", "reissen", "shipwreck", "authentic", "urban_c", "bt_falls", "l_ctf", "face-capture", "valhalla", "mbt1", "mach2", "dust2", "berlin_wall", "mercury", "akroseum", "europium", "abbey", "redemption", "damnation", "forge", "campo", "nitro", "core_refuge", "xenon", "desecration", "sacrifice", "core_transfer", "recovery", "infamy", "tortuga"}

modes["capture"] = { "urban_c", "nevil_c", "fb_capture", "nmp9", "c_valley", "lostinspace", "fc3", "face-capture", "nmp4", "nmp8", "hallo", "tempest", "monastery", "ph-capture", "hades", "fc4", "relic", "fc5", "paradigm", "corruption", "asteroids", "ogrosupply", "reissen", "akroseum", "duomo", "frostbyte", "c_egypt", "caribbian", "dust2", "campo", "killcore3", "damnation", "arabic", "cwcastle", "suburb", "abbey", "venice", "mercury", "core_transfer", "xenon", "forge", "tortuga", "core_refuge", "infamy", "tejen", "capture_night", "river_c", "serenity" }

modes["regen capture"] = { "urban_c", "nevil_c", "fb_capture", "nmp9", "c_valley", "lostinspace", "fc3", "face-capture", "nmp4", "nmp8", "hallo", "tempest", "monastery", "ph-capture", "hades", "fc4", "relic", "fc5", "paradigm", "corruption", "asteroids", "ogrosupply", "reissen", "akroseum", "duomo", "frostbyte", "c_egypt", "caribbian", "dust2", "campo", "killcore3", "damnation", "arabic", "cwcastle", "suburb", "abbey", "venice", "mercury", "core_transfer", "xenon", "forge", "tortuga", "core_refuge", "infamy", "tejen", "capture_night", "river_c", "serenity" }

motds = {
--TODO: add

}

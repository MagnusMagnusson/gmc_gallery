word = "EGG";
index = 0;
t = 0;
correct = 0;
keyboard_lastchar = "";

getNextWord = method(self, function(){
	var extraWords = ["OEUF","EGGS", "GGE", "EGGY", "OMELETTE", "SCRAMBLE", "YOLK"];
	var n = correct + 1;
	var dot = n % 3 == 0;
	var ex = n % 7 == 0;
	var quest = (dot && ex) || n % 13 == 0;
	var base_word = n % 10 == 0 ? extraWords[n % 7] : "EGG" 
	
	word = base_word + (quest ? "?" : (dot ? "." : (ex ? "!" : "")));
});
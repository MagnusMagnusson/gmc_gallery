// Don't lose the last few hits when leaving.
if(known && pending > 0 && sending == 0) send();

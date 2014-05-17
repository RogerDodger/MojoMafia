/*
 * Copyright (c) 2014 Cameron Thornton.
 *
 * This library is free software; you can redistribute it and/or modify it
 * under the same terms as Perl version 5.14.2.
 */

Array.prototype.randomElement = function() {
	return this[ Math.floor(Math.random() * this.length) ];
};

$(document).ready(function() {
	var dicts;

	var _r = function(n) { return Math.random() < n; };

	var getname = function() {
		var dict = dicts.randomElement();
		var n = 1 + _r(.5) + _r(.2) + _r(.1) + _r(.05);

		var name = "";
		for (var s = 0; s <= n; s++) {
			var i = 1;
			if (s === 0) i = 0;
			if (s === n) i = 2;

			name += dict[i].randomElement();
		}
		return name;
	};

	$('.namegen').click(function() {
		$(this).next().val(getname());
	});

	dicts = [[["A","Aeg","Am","An","Ang","Ar","Be","Ca","Ce","Cu","Dae","De","Di","E","Ear","Ec","El","Er","Fae","Fea","Fein","Fel","Fin","Ga","Gal","Gel","Gil","Glor","Guil","Gwai","Gwin","Hal","Hu","Hu","Ing","Id","Ind","Leg","Len","Lin","Lo","Luth","Maed","Maeg","Mag","Mah","Mir","Ner","Nim","Nin","Ol","Or","Ru","Ser","Tel","Thin","Thran","Tin","Tu","Tur","Um","Und","Vor"],["ar","be","bri","brim","brin","da","do","dri","du","du","ed","el","fin","gar","glo","go","gol","i","la","le","len","li","liv","lu","mi","nar","ne","ni","nu","ram","ran","re","red","rei","ren","ri","rin","ro","rod","ru","the","thi","tho","vi","wa"],["an","bar","bor","born","char","dal","dan","de","del","dor","dhel","dil","dir","el","en","eth","fin","glin","glor","gol","gon","gorm","gund","hil","hir","hros","il","ion","is","lad","las","lin","marth","miom","mil","mir","moth","nas","nion","nor","ol","on","oth","or","ras","red","reth","rin","rion","rod","ron","rond","ros","roth","stor","tan","thir","thor","we","wen","wing"]],[["A","An","Ar","As","Ba","Be","Ber","Bis","Bo","Bro","Ca","Cad","Cae","Cal","Car","Ce","Ch","Chro","Co","Cop","Cu","Dys","Er","Eu","Flu","Fran","Ga","Gal","Ger","Haf","He","Hol","Hy","In","Io","Ir","Kryp","Lan","Li","Lu","Mag","Man","Mer","Mo","Ne","Nep","Ni","Os","O","Pal","Phos","Pla","Plu","Po","Pra","Pro","Ra","Rhe","Rho","Ru","Sa","Scan","Se","Si","Sil","So","Stron","Sul","Tan","Tech","Tel","Ter","Thal","Tho","Thu","Ti","Tung","U","Va","Xe","Zir"],["bi","ci","co","cu","de","di","do","dro","dy","for","ga","i","ke","la","le","li","lo","lu","lyb","ma","me","mi","mo","na","ne","ni","o","pho","pi","pro","ra","ri","ro","ryl","se","seo","si","ta","tas","te","tha","the","thi","ti","to","tri","tro","tu","xy"],["balt","bon","con","dine","don","fur","gen","gon","lum","mine","muth","nese","nic","non","num","ny","on","per","rine","ron","rus","ry","sten","tine","ton","um","ver"]]];
});

/*
 * Copyright (c) 2013 Cameron Thornton.
 *
 * This library is free software; you can redistribute and/or modify it
 * under the same terms as Perl version 5.14.2.
 */
Array.prototype.randomElement=function(){return this[Math.floor(Math.random()*this.length)];};$(document).ready(function(){var dicts;var _r=function(n){return Math.random()<n;};var getname=function(){var dict=dicts.randomElement();var n=1+_r(.5)+_r(.2)+_r(.1)+_r(.05);var name="";for(var s=0;s<=n;s++){var i=1;if(s===0)i=0;if(s===n)i=2;name+=dict[i].randomElement();}
return name;};$('.namegen').click(function(){$(this).next().val(getname());});dicts=[[["A","Aeg","Am","An","Ang","Ar","Be","Ca","Ce","Cu","Dae","De","Di","E","Ear","Ec","El","Er","Fae","Fea","Fein","Fel","Fin","Ga","Gal","Gel","Gil","Glor","Guil","Gwai","Gwin","Hal","Hu","Hu","Ing","Id","Ind","Leg","Len","Lin","Lo","Luth","Maed","Maeg","Mag","Mah","Mir","Ner","Nim","Nin","Ol","Or","Ru","Ser","Tel","Thin","Thran","Tin","Tu","Tur","Um","Und","Vor"],["ar","be","bri","brim","brin","da","do","dri","du","du","ed","el","fin","gar","glo","go","gol","i","la","le","len","li","liv","lu","mi","nar","ne","ni","nu","ram","ran","re","red","rei","ren","ri","rin","ro","rod","ru","the","thi","tho","vi","wa"],["an","bar","bor","born","char","dal","dan","de","del","dor","dhel","dil","dir","el","en","eth","fin","glin","glor","gol","gon","gorm","gund","hil","hir","hros","il","ion","is","lad","las","lin","marth","miom","mil","mir","moth","nas","nion","nor","ol","on","oth","or","ras","red","reth","rin","rion","rod","ron","rond","ros","roth","stor","tan","thir","thor","we","wen","wing"]],[["A","An","Ar","As","Ba","Be","Ber","Bis","Bo","Bro","Ca","Cad","Cae","Cal","Car","Ce","Ch","Chro","Co","Cop","Cu","Dys","Er","Eu","Flu","Fran","Ga","Gal","Ger","Haf","He","Hol","Hy","In","Io","Ir","Kryp","Lan","Li","Lu","Mag","Man","Mer","Mo","Ne","Nep","Ni","Os","O","Pal","Phos","Pla","Plu","Po","Pra","Pro","Ra","Rhe","Rho","Ru","Sa","Scan","Se","Si","Sil","So","Stron","Sul","Tan","Tech","Tel","Ter","Thal","Tho","Thu","Ti","Tung","U","Va","Xe","Zir"],["bi","ci","co","cu","de","di","do","dro","dy","for","ga","i","ke","la","le","li","lo","lu","lyb","ma","me","mi","mo","na","ne","ni","o","pho","pi","pro","ra","ri","ro","ryl","se","seo","si","ta","tas","te","tha","the","thi","ti","to","tri","tro","tu","xy"],["balt","bon","con","dine","don","fur","gen","gon","lum","mine","muth","nese","nic","non","num","ny","on","per","rine","ron","rus","ry","sten","tine","ton","um","ver"]]];});if(Mafia.mode=='development'){$(document).ready(function(){var sheet=document.getElementById('main-stylesheet');(function watch_css(){console.log("Checking CSS");$.ajax({type:'GET',url:'/watch/css',success:function(res,status,xhr){if(sheet.href.match(/mtime=\d+$/)){sheet.href=sheet.href.replace(/\d+$/,res);}
else{sheet.href+='?mtime='+res;}},complete:watch_css});})();});}
$(document).ready(function(){var $container=$('.top_msg .container');if($container){var $btn=$('<div class="close-btn"></div>');$btn.html('<i class="icon-remove"></i> Dismiss');$btn.click(function(){$container.parent().remove();});$container.append($btn);}});function replaceSelection(e,newSelection){if('selectionStart'in e){e.focus();e.value=e.value.substr(0,e.selectionStart)
+newSelection.text
+e.value.substr(e.selectionEnd,e.value.length);e.selectionStart=newSelection.start;e.selectionEnd=newSelection.end;}
else if(document.selection){e.focus();document.selection.createRange().text=newSelection.text;}
else{e.value+=newSelection.text;}}
$(document).ready(function(){var $textarea=$('#NewPost').find('textarea');$('#NewPost .editor .btn-group .btn').click(function(){var selection=$textarea.getSelection();var $btn=$(this);if($textarea.attr("disabled")||$btn.hasClass("disabled")){return;}
if($btn.hasClass('italic')){selection.text='*'+selection.text+'*';selection.start+=1;selection.end+=1;}
else if($btn.hasClass('bold')){selection.text='**'+selection.text+'**';selection.start+=2;selection.end+=2;}
else if($btn.hasClass('quote')){selection.text=selection.text.replace(/^/mg,'> ');if(selection.start==selection.end){selection.end=selection.start+=2;}
else{selection.end+=2*selection.text.match(/^/mg).length;}}
else if($btn.hasClass('url')){var mask=selection.text!==''?selection.text:'link text';selection.text='['+mask+'](http://www.example.com)';selection.end=selection.start+selection.text.length-1;selection.start+=mask.length+3;}
replaceSelection($textarea.get(0),selection);});$('.post .controls .reply a').click(function(e){e.preventDefault();var postid=$(this).parentsUntil('.post')
.parent()
.find('.permalink a')
.attr('href')
.match(/\d+$/),selection=$textarea.getSelection();selection.text="#"+postid+"\n";selection.end=selection.start+=selection.text.length;$textarea.focus();replaceSelection($textarea.get(0),selection);});});$(document).ready(function(){var $preview_area=$("#NewPost .post.preview"),$preview_btn=$("#NewPost .senders .preview"),$edit_btn=$("#NewPost .senders .edit"),$wait_btn=$("#NewPost .senders .wait"),$textarea=$("#NewPost textarea"),$editor=$("#NewPost .editor");$preview_btn.click(function(e){$textarea.attr({"disabled":"disabled"});$preview_btn.addClass("hidden");$wait_btn.removeClass("hidden");$editor.find("li").each(function(i){$(this).addClass("disabled");});$.ajax({type:'POST',url:Mafia.paths["post-preview"],data:{"text":$textarea.val()},success:function(res,status,xhr){$preview_area.html(res);$textarea.addClass("hidden");$preview_area.removeClass("hidden");$edit_btn.removeClass("hidden");$editor.addClass("hidden");},error:function(xhr,status,err){alert(err);$edit_btn.click();},complete:function(xhr,status){$textarea.attr({"disabled":null});$wait_btn.addClass("hidden");$editor.find("li").each(function(i){$(this).removeClass("disabled");});}});});$edit_btn.click(function(e){$preview_area.html(' ');$preview_area.addClass("hidden");$textarea.removeClass("hidden");$edit_btn.addClass("hidden");$preview_btn.removeClass("hidden");$editor.removeClass("hidden");});});$(document).ready(function(){navigator.id.watch({loggedInUser:Mafia.user.email,onlogin:function(assertion){$.ajax({type:'POST',url:Mafia.paths["user-login"],data:{"assertion":assertion},success:function(res,status,xhr){if('redirect'in res){window.location=res.redirect;}else{window.location.reload();}},error:function(xhr,status,err){alert("Login failure: "+err);navigator.id.logout();}});},onlogout:function(){$.ajax({type:'POST',url:Mafia.paths["user-logout"],success:function(res,status,xhr){window.location.reload();},error:function(xhr,status,err){alert("Logout failure: "+err);}});}});$('#login')
.click(function(e){e.preventDefault();navigator.id.request({"siteName":"MojoMafia"});});$('#logout')
.click(function(e){e.preventDefault();navigator.id.logout();});});
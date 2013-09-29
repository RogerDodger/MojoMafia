/*
 * Copyright (c) 2013 Cameron Thornton.
 *
 * This library is free software; you can redistribute and/or modify it
 * under the same terms as Perl version 5.14.2.
 */
if(Mafia.mode=='development'){(function(){var sheet=document.getElementById('main-stylesheet');(function watch_css(){console.log("Checking CSS");$.ajax({type:'GET',url:'/watch/css',success:function(res,status,xhr){if(sheet.href.match(/mtime=\d+$/)){sheet.href=sheet.href.replace(/\d+$/,res);}
else{sheet.href+='?mtime='+res;}},complete:watch_css});})();})();}
function replaceSelection(e,newSelection){if('selectionStart'in e){e.focus();e.value=e.value.substr(0,e.selectionStart)+newSelection.text+e.value.substr(e.selectionEnd,e.value.length);e.selectionStart=newSelection.start;e.selectionEnd=newSelection.end;}
else if(document.selection){e.focus();document.selection.createRange().text=newSelection.text;}
else{e.value+=newSelection.text;}}
$(document).ready(function(){$('#NewPost .editor ul.controls li').click(function(){var textarea=$('#NewPost').find('textarea');var selection=textarea.getSelection();if($(this).hasClass('i')){selection.text='*'+selection.text+'*';selection.start+=1;selection.end+=1;}
else if($(this).hasClass('b')){selection.text='**'+selection.text+'**';selection.start+=2;selection.end+=2;}
else if($(this).hasClass('q')){selection.text=selection.text.replace(/^/mg,'> ');if(selection.start==selection.end){selection.end=selection.start+=2;}
else{selection.end+=2*selection.text.match(/^/mg).length;}}
else if($(this).hasClass('url')){var mask=selection.text!==''?selection.text:'link text';selection.text='['+mask+'](http://www.example.com)';selection.start+=mask.length+3;selection.end+=selection.text.length-1;}
replaceSelection(textarea.get(0),selection);});$('.post .controls .reply a').click(function(e){e.preventDefault();var textarea=$('#NewPost').find('textarea');var selection=textarea.getSelection();var link="#"+$(this).parentsUntil('.post').parent().find('.permalink a').attr('href').match(/\d+$/)+"\n";selection.text=link;selection.end=selection.start+=link.length;textarea.focus();replaceSelection(textarea.get(0),selection);});$('#NewPost .buttons .preview').click(function(e){var data={text:$('#NewPost').find('textarea').val()};$.post('/post/preview',data,function(res){$('#NewPost + .preview').removeClass('hidden');$('#NewPost + .preview').find('.body').html(res);});});$('#NewPost + .preview').find('.close').click(function(e){$('#NewPost + .preview').addClass('hidden');});});$(document).ready(function(){navigator.id.watch({loggedInUser:Mafia.user.email,onlogin:function(assertion){$.ajax({type:'POST',url:'/login',data:{"assertion":assertion},success:function(res,status,xhr){if('redirect'in res){window.location=res.redirect;}else{window.location.reload();}},error:function(xhr,status,err){alert("Login failure: "+err);navigator.id.logout();}});},onlogout:function(){$.ajax({type:'POST',url:'/logout',success:function(res,status,xhr){window.location.reload();},error:function(xhr,status,err){alert("Logout failure: "+err);}});}});$('#login')
.click(function(e){e.preventDefault();navigator.id.request({"siteName":"MojoMafia"});});$('#logout')
.click(function(e){e.preventDefault();navigator.id.logout();});});
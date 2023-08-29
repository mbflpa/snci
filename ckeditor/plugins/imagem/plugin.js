function AbrirFormUpload(url,w,h,editorTexto) {
    var dir='';
    // alert(sessionStorage.getItem('dirImagens'))
    // if(sessionStorage.getItem('dirImagens')){
    //    dir=sessionStorage.getItem('dirImagens');
    // }else{
    //     dir ='imagens';
    //     sessionStorage.setItem('dirImagens','imagens');
    // }

    var newW = w + 100;
    var newH = h + 100;
    var left = (screen.width-newW)/2;
    var top = (screen.height-newH)/2;
    url = url + '?editor=' + editorTexto +  '&dir=imagens';
    var newwindow = window.open(url, 'name', 'width='+newW+',height='+newH+',left='+left+',top='+top+ ',toolbar=no,location=no, directories=no, status=no, menubar=no,resizable=yes,scrollbars=yes, copyhistory=no');
    newwindow.resizeTo(newW, newH);
    //posiciona o popup no centro da tela
    newwindow.moveTo(left, top);
    newwindow.focus();
    return false;
}

CKEDITOR.plugins.add( 'imagem', {
    icons: 'imagem',
    init: function( editor ) {
        editor.addCommand("abrirFormUpload", { 
            exec: function(edt) {
                AbrirFormUpload('formUploadImagem.cfm',700,380,edt.name);
            }
        });

        
        
        editor.ui.addButton('Imagem', { 
            label: "Click para inserir uma imagem.",
            command: 'abrirFormUpload',
            toolbar: 'insert',
            icon: "../ckeditor/plugins/imagem/icons/imgIco.png"
        });

        if ( editor.contextMenu ) {
            editor.addMenuGroup( 'imagemGroup' );
            editor.addMenuItem( 'imagemItem', {
                label: 'Edit Abbreviation',
                icon: "../ckeditor/plugins/imagem/icons/imageupload.png",
                command: 'abrirFormUpload',
                group: 'imagemGroup'
            });
        }

        
        
    }
});


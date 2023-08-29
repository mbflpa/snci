CKEDITOR.dialog.add( 'imagemDialog', function( editor ) {
    return {
        title: 'Imagemeviation Properties',
        minWidth: 400,
        minHeight: 200,

        contents: [
            {
                id: 'tab-basic',
                label: 'Basic Settings',
                elements: [
                    {
                        type: 'text',
                        id: 'imagem',
                        label: 'Imagemeviation',
                        validate: CKEDITOR.dialog.validate.notEmpty( "Imagemeviation field cannot be empty." ),

                        setup: function( element ) {
                            this.setValue( element.getText() );
                        },

                        commit: function( element ) {
                            element.setText( this.getValue() );
                        }
                    },
                    {
                        type: 'text',
                        id: 'title',
                        label: 'Explanation',
                        validate: CKEDITOR.dialog.validate.notEmpty( "Explanation field cannot be empty." ),

                        setup: function( element ) {
                            this.setValue( element.getAttribute( "title" ) );
                        },

                        commit: function( element ) {
                            element.setAttribute( "title", this.getValue() );
                        }
                    }
                ]
            },

            {
                id: 'tab-adv',
                label: 'Advanced Settings',
                elements: [
                    {
                        type: 'text',
                        id: 'id',
                        label: 'Id',

                        setup: function( element ) {
                            this.setValue( element.getAttribute( "id" ) );
                        },

                        commit: function ( element ) {
                            var id = this.getValue();
                            if ( id )
                                element.setAttribute( 'id', id );
                            else if ( !this.insertMode )
                                element.removeAttribute( 'id' );
                        }
                    }
                ]
            }
        ],

        onShow: function() {
            var selection = editor.getSelection();
            var element = selection.getStartElement();

            if ( element )
                element = element.getAscendant( 'imagem', true );

            if ( !element || element.getName() != 'imagem' ) {
                element = editor.document.createElement( 'imagem' );
                this.insertMode = true;
            }
            else
                this.insertMode = false;

            this.element = element;
            if ( !this.insertMode )
                this.setupContent( this.element );
        },

        onOk: function() {
            AbrirPopup('formUploadImagem.cfm',600,400);
            var dialog = this;
            var imagem = this.element;
            this.commitContent( imagem );

            if ( this.insertMode )
                editor.insertElement( imagem );
        }
    };
});
function AbrirPopup(url,w,h) {
    var newW = w + 100;
    var newH = h + 100;
    var left = (screen.width-newW)/2;
    var top = (screen.height-newH)/2;

    var newwindow = window.open(url, 'name', 'width='+newW+',height='+newH+',left='+left+',top='+top+ ',toolbar=no,location=no, directories=no, status=no, menubar=no,scrollbars=yes, copyhistory=no');
    newwindow.resizeTo(newW, newH);
    //posiciona o popup no centro da tela
    newwindow.moveTo(left, top);
    newwindow.focus();
    return false;
}
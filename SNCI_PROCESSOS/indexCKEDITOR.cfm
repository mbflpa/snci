<!DOCTYPE html>
<!--
Copyright (c) 2003-2022, CKSource Holding sp. z o.o. All rights reserved.
For licensing, see LICENSE.md or https://ckeditor.com/legal/ckeditor-oss-license
-->
<html lang="pt-br">
<head>
	<meta charset="UTF-8">
	<title>CKEditor Sample</title>
	<script src="ckeditor/ckeditor.js"></script>

	<meta name="viewport" content="width=device-width,initial-scale=1">
	<meta name="description" content="Try the latest sample of CKEditor 4 and learn more about customizing your WYSIWYG editor with endless possibilities.">
</head>

<body id="main">
	<div class="adjoined-bottom">
		<div >
			<div >
				<div id="editor1"></div>
			</div>
		</div>
	</div>
<script>
	CKEDITOR.replace( 'editor1', {
		width: '100%',
		height: 350,
		//extraPlugins: 'imagem,table,tableresize,image2',
		extraPlugins: 'table,tableresize,base64image,image2',
		disableNativeSpellChecker: false,
		removeButtons: 'PasteFromWord',
		toolbar: [
			
			[ 'Source','Preview', 'Print', '-' ],
			[ 'Cut', 'Copy', 'Paste', 'PasteText', 'RemoveFormat', '-', 'Undo', 'Redo', '-','Find','-','SelectAll'],
			[ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-' ],
			[ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-'], 
				'/',
			['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock','-'], 
			['HorizontalRule','SpecialChar', '-', 'Styles', 'Font','FontSize','TextColor', 'BGColor', 'CreateDiv','-', 'Base64image', '-', 'Table','-', 'Maximize'  ]
		]

	} );
</script>

</body>
</html>

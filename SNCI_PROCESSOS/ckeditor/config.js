/**
 * @license Copyright (c) 2003-2022, CKSource Holding sp. z o.o. All rights reserved.
 * For licensing, see https://ckeditor.com/legal/ckeditor-oss-license
 */

CKEDITOR.editorConfig = function( config ) {
	
	// %REMOVE_START%
	// The configuration options below are needed when running CKEditor from source files.
	config.plugins = 'dialogui,dialog,about,a11yhelp,dialogadvtab,basicstyles,bidi,blockquote,notification,button,toolbar,clipboard,panelbutton,panel,floatpanel,colorbutton,colordialog,xml,ajax,templates,menu,contextmenu,copyformatting,div,editorplaceholder,resize,elementspath,enterkey,entities,popup,filetools,find,floatingspace,listblock,richcombo,font,fakeobjects,forms,format,horizontalrule,htmlwriter,iframe,wysiwygarea,indent,indentblock,indentlist,smiley,justify,menubutton,language,link,list,liststyle,magicline,maximize,newpage,pagebreak,pastetext,pastetools,pastefromgdocs,pastefromlibreoffice,pastefromword,preview,print,removeformat,save,selectall,showblocks,showborders,sourcearea,specialchar,scayt,stylescombo,tab,table,tabletools,tableselection,undo,lineutils,widgetselection,widget,notificationaggregator,uploadwidget';
	config.skin = 'office2013';
	config.defaultLanguage = 'pt-br';
	//config.width = 1020;
	// %REMOVE_END%

	// config.uiColor = '#AADC6E';

	config.extraPlugins= 'table,tableresize,base64image,imageresize';
	config.disableNativeSpellChecker= false;
	config.removeButtons= 'PasteFromWord';

	config.toolbar= [
		{ name: 'document', items: [ 'Source', '-', 'Save', 'NewPage', 'Preview', 'Print'] },
		{ name: 'clipboard', items: [ 'Cut', 'Copy', 'Paste', 'PasteText', 'RemoveFormat', '-', 'Undo', 'Redo', '-','Find','-','SelectAll' ] },
		{ name: 'styles', items: ['Styles', 'Format'] },
		{ name: 'basicstyles', items: [  'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'CopyFormatting', 'RemoveFormat'  ] },
		{ name: 'colors', items: [ 'TextColor', 'BGColor' ] },
		{ name: 'align', items: [ 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock' ] },
		{ name: 'links', items: [ 'Link', 'Unlink' ] },
		{ name: 'paragraph', items: [ 'NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-', 'Blockquote' ] },
		{ name: 'insert', items: ['base64image', 'Table', 'HorizontalRule', 'SpecialChar', 'PageBreak' ] },
		{ name: 'tools', items: [ 'Maximize' ] }
	];
	config.disallowedContent= 'img{width,height,float}';
	config.extraAllowedContent= 'img[width,height,align]';
	config.bodyClass= 'document-editor';
	config.format_tags= 'p;h1;h2;h3;pre';
	config.removeDialogTabs= 'image:advanced;link:advanced';
	config.removePlugin= 'image, image2';
	config.stylesSet= [
		/* Inline Styles */
		{ name: 'Marker', element: 'span', attributes: { 'class': 'marker' } },
		{ name: 'Cited Work', element: 'cite' },
		{ name: 'Inline Quotation', element: 'q' },

		/* Object Styles */
		{
			name: 'Special Container',
			element: 'div',
			styles: {
				padding: '5px 10px',
				background: '#eee',
				border: '1px solid #ccc'
			}
		},
		{
			name: 'Compactar tabela',
			element: 'table',
			attributes: {
				cellpadding: '5',
				cellspacing: '0',
				border: '1',
				bordercolor: '#ccc'
			},
			styles: {
				'border-collapse': 'collapse'
			}
		},
		{ name: 'Tabela sem bordas', element: 'table', styles: { 'border-style': 'hidden', 'background-color': '#E6E6FA' } },
		{ name: 'i, ii, iii, iv, v, etc.', element: 'ul', styles: { 'list-style-type': 'lower-roman' } },
		{ name: 'I, II, III, IV, V, etc.', element: 'ul', styles: { 'list-style-type': 'upper-roman' } },
		{ name: 'a, b, c, d, e, etc.', element: 'ul', styles: { 'list-style-type': 'lower-latin' } },

	]
};
CKEDITOR.config.allowedContent = true;
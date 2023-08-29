/**
 * @license Copyright (c) 2003-2019, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see https://ckeditor.com/legal/ckeditor-oss-license
 */

CKEDITOR.editorConfig = function( config ) {
	// Define changes to default configuration here. For example:
	// config.uiColor = '#AADC6E';
	config.defaultLanguage = 'pt-br';
	config.width = 1020;
	// config.skin = 'moono-dark';
	config.extraPlugins = 'imagem,table,tableresize';
	// config.toolbarCanCollapse = true;
	// config.removePlugins = 'image';
};

CKEDITOR.config.allowedContent = true;
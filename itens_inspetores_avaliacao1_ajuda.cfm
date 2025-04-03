<cfprocessingdirective pageEncoding ="utf-8">  

<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	<cfinclude template="permissao_negada.htm">
	<cfabort>
</cfif>
  
<cfquery name="qItemAjuda" datasource="#dsn_inspecao#">
	SELECT * FROM Itens_Verificacao
	INNER JOIN Grupos_Verificacao ON Itn_NumGrupo = Grp_Codigo and Grp_Ano = Itn_Ano
	WHERE Itn_Ano=RIGHT('#url.numero#',4) AND Grp_Ano=RIGHT('#url.numero#',4) and Itn_NumGrupo='#url.numgrupo#' and Itn_NumItem ='#url.numitem#'
</cfquery>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<script type="text/javascript" src="ckeditor/ckeditor.js"></script>
	<title>SNCI - AVALIAÇÃO DE ITENS - AJUDA</title>
	<link rel="stylesheet" type="text/css" href="view.css" media="all">
</head>
<body id="main_body"  >
	<img alt="Ajuda do Item" src="figuras/ajudaItem.png" width="35"  border="0" style="position:absolute;left:2px;top:5px"></img>
	<div align="left" style="margin-left:15px;width:790px;margin-top:15px">	
		<div>
			<p style="color:white;text-align:justify;font-size: 14px">Grupo: <cfoutput><strong>#qItemAjuda.Itn_NumGrupo# - #trim(qItemAjuda.Grp_Descricao)#</strong></cfoutput></p>
		
			<p style="color:white;text-align:justify;position:relative;top:-10px;font-size: 12px">Item: <cfoutput><strong>#qItemAjuda.Itn_NumItem# - #trim(qItemAjuda.Itn_Descricao)#</strong></cfoutput></p>
		</div>
		<div>
			<label style="color:white"><strong>Orientação:</strong></label>
		</div>
		<div>
			<textarea readOnly = true name="ajudaAvaliacao" id="ajudaAvaliacao" style="background:#fff;color:black;text-align:justify;">              
				<cfoutput>
					<strong><u><i>COMO EXERCUTAR/PROCEDIMENTOS ADOTADOS:</i></u></strong>#qItemAjuda.Itn_Orientacao#<br>
					<strong><u><i>AMOSTRA:</i></u></strong>#qItemAjuda.Itn_Amostra#<br>
					<strong><u><i>NORMA:</i></u></strong>#qItemAjuda.Itn_Norma#<br>
				</cfoutput>
			</textarea>
		</div>
	</div>
	
</body>
<script type="text/javascript">
//configurações diferenciadas do editor de texto.
CKEDITOR.replace('ajudaAvaliacao', {
	width: '950',
	height: 500,
	toolbar:[
		{ name: 'document', items: ['Preview', 'Print', '-' ] },
		], 
			
		// Remove the redundant buttons from toolbar groups defined above.
		//removeButtons:'Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Find,Replace,SelectAll,CopyFormatting,RemoveFormat'
		// removeButtons: 'Source,Save,NewPage,ExportPdf,Templates,Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Find,Replace,SelectAll,Scayt,Form,Radio,TextField,Textarea,Select,ImageButton,HiddenField,Button,Bold,Italic,Underline,Strike,Subscript,Superscript,CopyFormatting,RemoveFormat,NumberedList,BulletedList,Outdent,Indent,Blockquote,CreateDiv,JustifyLeft,JustifyCenter,JustifyRight,JustifyBlock,BidiLtr,BidiRtl,Language,Link,Unlink,Anchor,Image,Flash,Table,HorizontalRule,Smiley,SpecialChar,PageBreak,Iframe,Styles,Format,Font,FontSize,TextColor,BGColor,Maximize,ShowBlocks,About,Checkbox'

})
</script>
</html>





	


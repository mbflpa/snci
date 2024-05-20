
<cfprocessingdirective pageEncoding ="utf-8">
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
	<cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>

<cfquery name="qAcesso" datasource="#dsn_inspecao#">
	select Usu_DR, RTRIM(LTRIM(Usu_GrupoAcesso)) AS Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido, Usu_Coordena 
	from usuarios 
	where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
</cfquery>

<cfquery datasource="#dsn_inspecao#" name="rsItemSelecionado">
    SELECT Itn_Orientacao, Itn_Amostra, Itn_Norma, TUI_Modalidade,TUI_TipoUnid,TUI_Ativo, TUI_Ano, TUI_GRUPOITEM, TUI_ITEMVERIF, TUN_Descricao,  Grp_Descricao, Itn_Descricao,Itn_ValorDeclarado 
    FROM TipoUnidade_ItemVerificacao 
    INNER JOIN Grupos_Verificacao ON Grp_Codigo = TUI_GrupoItem AND Grp_Ano = TUI_Ano 
    INNER JOIN Itens_Verificacao ON Itn_Ano = TUI_Ano and TUI_Modalidade=Itn_Modalidade AND Itn_NumGrupo = TUI_GrupoItem and Itn_NumItem = TUI_ItemVerif and  TUI_TipoUnid = Itn_TipoUnidade
    INNER JOIN Tipo_Unidades ON TUN_Codigo = TUI_TipoUnid
    WHERE TUI_Ano = '#url.selAnoConsulta#'
            AND TUI_TipoUnid = '#url.selTipoConsulta#'
            AND TUI_Modalidade = '#url.selModConsulta#'
            AND TUI_GrupoItem = '#url.selGrupoConsulta#'
			AND TUI_ITEMVERIF = '#url.selItemConsulta#'
</cfquery>
<cfquery datasource="#dsn_inspecao#" name="rsTipoItem">
    SELECT DISTINCT TUN_Codigo, TUN_Descricao FROM TipoUnidade_ItemVerificacao 
	INNER JOIN Tipo_Unidades ON TUN_Codigo = TUI_TipoUnid
	WHERE TUI_Ano = '#url.selAnoConsulta#'
          AND TUI_Modalidade = '#url.selModConsulta#'
          AND TUI_GrupoItem = '#url.selGrupoConsulta#'
		  AND TUI_ITEMVERIF = '#url.selItemConsulta#'
    ORDER BY TUN_Descricao
</cfquery>


<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>SNCI - ORIENTAÇÕES DO ITEM</title>
<link rel="stylesheet" type="text/css" href="view.css" media="all">
<!--- <script type="text/javascript" src="ckeditor/ckeditor.js"></script> --->

<script type="text/javascript">

</script>

</head>
	<body id="main_body"  onload="CKEDITOR.replace( 'consultaItemOrientacao' )" style="background:#003366">
   		<form id="form1" name="form1" onSubmit="" method="post" >
		   	<div align="left" style="margin-left:10px;color:#fff;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:12px">
				<cfoutput>
					<div  style="margin-bottom:10px;">Grupo: <strong style="">#rsItemSelecionado.TUI_GrupoItem#-#rsItemSelecionado.Grp_Descricao#</strong></div>	 
					<div  style="margin-bottom:10px;">Item: <strong  style="">#rsItemSelecionado.TUI_ITEMVERIF#-#rsItemSelecionado.Itn_Descricao#</strong></div>	 
					<!---<div  style="margin-bottom:10px;">
						Tipos de Unidade: <strong  style="">#ValueList(rsTipoItem.TUN_Descricao,', ')#</strong> 
						<label style="margin-left:30px;">Modalidade: <strong  style=""><cfif #rsItemSelecionado.TUI_Modalidade# eq 0>PRESENCIAL<cfelse>A DIST�NCIA</cfif></label></strong>	 
						<label style="margin-left:30px;">Situação: <strong  style=""><cfif #rsItemSelecionado.TUI_Ativo# eq 0>DESATIVADO<cfelse>ATIVO</cfif></label></strong>
					</div>--->	 
				</cfoutput>
			</div>
				 
			<div align="center" >
                <textarea readOnly = true name="consultaItemOrientacao" id="consultaItemOrientacao" 
                          style="display:none!important;background:#fff;font-family:Verdana, Arial, Helvetica, sans-serif">
						  <cfoutput>
							<strong><u><i>COMO EXERCUTAR/PROCEDIMENTOS ADOTADOS:</i></u></strong>#rsItemSelecionado.Itn_Orientacao#<br>
							<strong><u><i>AMOSTRA:</i></u></strong>#rsItemSelecionado.Itn_Amostra#<br>
							<strong><u><i>NORMA:</i></u></strong>#rsItemSelecionado.Itn_Norma#<br>
						  </cfoutput>
				</textarea>		
            </div>          
		</form>
	</body>
<script>
         //configura��es diferenciadas do editor de texto.
            CKEDITOR.replace('consultaItemOrientacao', {
            width: '98%',
      		height: 250,
			toolbar:[
			{ name: 'document', items: ['Preview', 'Print', '-' ] },
			{ name: 'colors', items: [ 'TextColor', 'BGColor' ] },
			{ name: 'styles', items: [ 'Styles'] },
			{ name: 'basicstyles', items: [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ] },
			{ name: 'paragraph', items: [ 'NumberedList', 'BulletedList', '-',  'Blockquote','-','Outdent', 'Indent', '-', 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-', 'BidiLtr', 'BidiRtl' ] },
			{ name: 'insert', items: [ 'Table' ] },		
			{ name: 'insert', items: [ 'HorizontalRule' ] }
			], 
			   
            // Remove the redundant buttons from toolbar groups defined above.
			removeButtons:'Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Find,Replace,SelectAll,CopyFormatting,RemoveFormat'
            // removeButtons: 'Source,Save,NewPage,ExportPdf,Templates,Cut,Copy,Paste,PasteText,PasteFromWord,Undo,Redo,Find,Replace,SelectAll,Scayt,Form,Radio,TextField,Textarea,Select,ImageButton,HiddenField,Button,Bold,Italic,Underline,Strike,Subscript,Superscript,CopyFormatting,RemoveFormat,NumberedList,BulletedList,Outdent,Indent,Blockquote,CreateDiv,JustifyLeft,JustifyCenter,JustifyRight,JustifyBlock,BidiLtr,BidiRtl,Language,Link,Unlink,Anchor,Image,Flash,Table,HorizontalRule,Smiley,SpecialChar,PageBreak,Iframe,Styles,Format,Font,FontSize,TextColor,BGColor,Maximize,ShowBlocks,About,Checkbox'
   
            });
            
    </script>
</html>





	


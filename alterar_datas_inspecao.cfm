<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
<link href="CSS.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
.style5 {color: #11438B}
-->
</style>
</head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<body>
<div id="Layer1" style="position:absolute; left:11px; top:6px; width:7px; height:6px; z-index:1"></div>
<div align="center"></div>
<a name="Inicio" id="Inicio"></a>
<cfform action="arquivo_dbins_transmitir.cfm" method="Post" name="frmObjeto" o>
<table width="286" align="center">
  
      <tr>
        <td width="278"><div align="center"><span class="style1">Altera&ccedil;&atilde;o conclu&iacute;da com sucesso!</span> </div></td>
      </tr>
      
      <tr>
      <td height="29"><div align="center">
        <input name="Submit2" type="submit" class="botao" value="Voltar" >
      </div></td>
      </tr>
  </table>

</cfform>

 <cfset DataI = form.data_inicial>
 <cfset DataF = form.data_final>
 <cfset num = num_insp>

<cfquery datasource="#dsn_inspecao#">
  set  dateformat dmy
</cfquery>

<cfquery datasource="#dsn_inspecao#">
UPDATE Inspetor_Inspecao SET Inspetor_Inspecao.IPT_DtInicInsp = '#DataI#', Inspetor_Inspecao.IPT_DtFimInsp = '#DataF#', Inspetor_Inspecao.IPT_DtInicDesloc = '#DataI#', Inspetor_Inspecao.IPT_DtFimDesloc = '#DataF#'
WHERE (((Inspetor_Inspecao.IPT_NumInspecao)='#num#'));
</cfquery>

<cfquery datasource="#dsn_inspecao#">
UPDATE Inspecao SET Inspecao.INP_DtInicInspecao = '#DataI#', Inspecao.INP_DtFimInspecao = '#DataF#', Inspecao.INP_DtInicDeslocamento = '#DataI#', Inspecao.INP_DtFimDeslocamento = '#DataF#'
WHERE (((Inspecao.INP_NumInspecao)='#num#'));
</cfquery>

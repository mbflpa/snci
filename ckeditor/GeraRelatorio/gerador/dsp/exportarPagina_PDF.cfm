<!------------------------------------------------------------------>
<!---@Nome: Relatório de atividades -------------------------------->
<!---@Descrição: Página geradora de relatório no formato PDF ------->
<!---@Data: 22/05/2010 --------------------------------------------->
<!---@Autor: Sandro Mendes - GESIT/SSAD----------------------------->
<!------------------------------------------------------------------>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>SARIN - Relatório de Auditoria</title>
<link href="../../geral/css/form_style.css" rel="stylesheet" type="text/css" />
<style type="text/css">
<!--
.style2 {
	font-size: 24px;
	font-weight: bold;
}
-->
</style>
</head>

<body>

<cfdocument format="pdf" pagetype="a4" orientation="portrait" scale="75">

	<link href="../../geral/css/form_style.css" rel="stylesheet" type="text/css" media="print" />
	
	<cfinvoke component="gerencias.ginsp.sins.rotinas.GeraRelatorio.gerador.ctrl.controller" 
	method="geraRelatorio" returnvariable="qryRelatorio">	
	</cfinvoke>
	
	
	<!---<cfdocumentsection>--->
	
	<table border="0" width="60%">
  <tr>
    <th rowspan="3"><div align="left"><img src="../../geral/img/logoCorreios.gif" alt="Logo ECT" align="left" /></div></th>
    <th align="left"><font size="3">Diretoria Regional de Pernambuco</font></th>
  </tr>
  <tr>
    <th align="left"><font size="3">Ger&ecirc;ncia de Inspe&ccedil;&atilde;o</font></th>
  </tr>
  <tr>
    <th align="left"><font size="3">Relat&oacute;rio de Auditoria </font></th>
  </tr>
</table>
  <table width="95%" border="0" cellspacing="4">
  <tr>
    <th width="25%" valign="top" bordercolor="#999999" bgcolor="#F5F5F5" scope="row"><div align="left"></div></th>
    <td bgcolor="#F5F5F5"><div align="justify"></div></td>
  </tr>
  <tr>
    <th width="25%" valign="top" bordercolor="#999999" bgcolor="#F5F5F5" scope="row"><div align="left" class="labelcell">Unidade:</div></th>
    <td bgcolor="#F5F5F5"><div align="justify"><cfoutput>#qryRelatorio.Und_Descricao#</cfoutput></div></td>
  </tr>
  <tr>
    <th width="25%" valign="top" bordercolor="#999999" bgcolor="#F5F5F5" scope="row"><div align="left" class="labelcell">Per&iacute;odo da Inspe&ccedil;&atilde;o:</div></th>
    <td bgcolor="#F5F5F5"><div align="justify"><cfoutput>#DateFormat(qryRelatorio.INP_DtInicInspecao,'dd/mm/yyyy')#</cfoutput>

      <label class="fieldcell"> 
      a      </label>
    <cfoutput>#DateFormat(qryRelatorio.INP_DtFimInspecao,'dd/mm/yyyy')#</cfoutput></div></td>
  </tr>
  <tr>
    <th width="25%" valign="top" bordercolor="#999999" bgcolor="#F5F5F5" scope="row"><div align="left" class="labelcell">N&ordm; da Inspe&ccedil;&atilde;o:</div></th>
    <td bgcolor="#F5F5F5"><div align="justify"><cfoutput>#qryRelatorio.INP_NumInspecao#</cfoutput></div></td>
  </tr>
  <tr>
    <th width="25%" valign="top" bordercolor="#999999" bgcolor="#F5F5F5" scope="row"><div align="left"></div></th>
    <td bgcolor="#F5F5F5"><div align="justify"></div></td>
  </tr>
  <cfoutput query="qryRelatorio">
  <tr>
    <th width="25%" valign="top" bordercolor="##999999" bgcolor="##F5F5F5" scope="row">
      <div align="left" class="labelcell">Objetivo:</div>
    </th>
    <td bgcolor="##F5F5F5"><div align="justify"><cfoutput>#Grp_Descricao#</cfoutput></div></td>
  </tr>
  <tr>
    <th width="25%" valign="top" bordercolor="##999999" bgcolor="##F5F5F5" scope="row"><div align="left" class="labelcell">Item:</div></th>
    <td bgcolor="##F5F5F5"><div align="justify"><cfoutput>#Itn_Descricao#</cfoutput></div></td>
  </tr>
  <tr>
    <th width="25%" valign="top" bordercolor="##999999" bgcolor="##F5F5F5" scope="row"><div align="left" class="labelcell">Situa&ccedil;&atilde;o Encontrada::</div></th>
    <td bgcolor="##F5F5F5"><div align="justify"><cfoutput>#RIP_Comentario#</cfoutput></div></td>
  </tr>
  <tr>
    <th width="25%" valign="top" bordercolor="##999999" bgcolor="##F5F5F5" scope="row"><div align="left" class="labelcell">Recomenda&ccedil;&otilde;es do Auditor:</div></th>
    <td bgcolor="##F5F5F5"><div align="justify"><cfoutput>#RIP_Recomendacoes#</cfoutput></div></td>
  </tr>
  <tr>
    <th width="25%" valign="top" bordercolor="##999999" bgcolor="##F5F5F5" scope="row"><div align="left" class="labelcell">Parecer:</div></th>
    <td bgcolor="##F5F5F5"><div align="justify"><cfoutput>#Replace(Pos_Parecer, '--------------------------------------------------------------------------------------------------------------', '<br /><br />', 'all')#</cfoutput></div></td>
  </tr>
  <tr>
    <th width="25%" valign="top" bordercolor="##999999" bgcolor="##CCCCCC" scope="row"><div align="left">&nbsp;</div></th>
    <td bgcolor="##CCCCCC"><div align="justify"></div></td>
  </tr>
  </cfoutput>
  <tr>
    <th width="25%" valign="top" bordercolor="#999999" scope="row"><div align="left"></div></th>
    <td bgcolor="#CCCCCC"><div align="justify"></div></td>
  </tr>
</table>


	<!---</cfdocumentsection>--->
</cfdocument>
</body>
</html>
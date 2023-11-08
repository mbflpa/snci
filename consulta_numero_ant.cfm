<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="permissao_negada.htm">
  <cfabort>
</cfif>

<cfquery name="qorgao" datasource="#dsn_inspecao#">
SELECT und_codigo AS org_numero, und_descricao AS org_no  FROM Unidades  ORDER BY und_descricao
</cfquery>
<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
.texto {
	border: none;
}
-->
</style>
<style type="text/css">
<!--
-->
</style>
<link href="css.css" rel="stylesheet" type="text/css">

</head>

<body >
<div align="center"></div>
<p>&nbsp;</p>
<p align="center">&nbsp;</p>
<p align="center" class="titulo1"><font size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>Pesquisa de satisfa&ccedil;&atilde;o por Nome do &Oacute;rg&Atilde;o</strong></font></p>
<p>&nbsp;</p>
<cfform action="consulta_numero.cfm" method="post" name="form1" target="_blank">

        <div align="center"><br>
          <cfselect name="nome_orgao" class="titulos" id="nome_orgao" style="border:none;background-color:lightyellow" query="qOrgao" value="org_no" display="org_no">          </cfselect>
          &nbsp;          <strong>
          <input name="submit" type='submit' style='font:10pt Verdana, Arial, Helvetica, sans-serif; border:1 solid #000000; cursor:hand; background:#FFFF99; color: #000000; ' value="Consultar">
          </strong> <font size="2"> </font></font><font size="2" face="Verdana, Arial, Helvetica, sans-serif"> </font>
  </div>
          </td>
          </tr>

        </div>
</cfform>
</body>
</html>
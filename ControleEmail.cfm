<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>


<html>
<head>
<title>Sistema de Acompanhamento das Respostas das Inspeções</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
.texto {
	border: thin none #000000;
}
-->
</style>
<link href="css.css" rel="stylesheet" type="text/css">

<script type="text/javascript">
function troca(a,b){
  document.formx.sninsp.value=a;
  document.formx.sacao.value=b;

if (confirm ("Deseja continuar processo de Cobrança por E-mail?"))
   { document.formx.submit(); }
else
   {//history.go(0);
   return false;
   }
}
</script>
</head>
<body>
<!--- Início da área de conteúdo --->
<!--- <cfquery name="rsPesq" datasource="#dsn_inspecao#">
SELECT DISTINCT  Pos_Inspecao, INP_DtInicInspecao
FROM ParecerUnidade INNER JOIN Inspecao on Pos_Inspecao=INP_NumInspecao
WHERE Year(INP_DtInicInspecao) = Year(getdate())
ORDER BY Pos_Inspecao
</cfquery>
 --->
<cfquery name="rsPesq" datasource="#dsn_inspecao#">
SELECT DISTINCT Pos_Inspecao, Und_Descricao
FROM (dbo.Inspecao INNER JOIN dbo.ParecerUnidade ON (dbo.Inspecao.INP_NumInspecao = dbo.ParecerUnidade.Pos_Inspecao) AND (dbo.Inspecao.INP_Unidade = dbo.ParecerUnidade.Pos_Unidade)) INNER JOIN dbo.Unidades ON dbo.ParecerUnidade.Pos_Unidade = dbo.Unidades.Und_Codigo
WHERE Year(INP_DtFimInspecao) = Year(getdate())
ORDER BY Und_Descricao
</cfquery>
<table width="479" border="0">
  <cfif rsPesq.Recordcount gt 0>
    <tr class="destaque"  bgcolor="eeeeee">
      <td width="130" height="23" align="center" class="exibir"><div align="center">N&ordm; Inspe&ccedil;&atilde;o</div></td>
      <td colspan="3" align="center" bgcolor="eeeeee" class="exibir"><div align="center"> Unidade&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<button name="submitAlt" type="button" class="exibir" onClick="troca('0','ger');">Cobrar a Todas</button>
      </div></td>
    </tr>
    <cfoutput query="rsPesq">
      <cfquery name="rsQuest" datasource="#dsn_inspecao#">
  SELECT Pes_NumInspecao FROM Pesquisa WHERE Pes_NumInspecao ='#rsPesq.Pos_Inspecao#'
</cfquery>
      <cfset scolor= "f7f7f7">
      <cfif rsQuest.Recordcount lte 0>
        <form method="POST" name="form" action="">
          <tr bgcolor="#scolor#">
            <td><div align="center" class="exibir">#rsPesq.Pos_Inspecao#</div></td>
            <td width="306" class="texto style2"><div align="left"><span class="exibir">#rsPesq.Und_Descricao#</span>
              <input name="frmninsp" type="hidden" id="frmninsp" value="#rsPesq.Pos_Inspecao#">
            </div></td>
            <td width="64" class="texto style2"><button name="submitAlt" type="button" class="exibir" onClick="troca(frmninsp.value,'unit');">Cobrar</button></td>
          </tr>
         <cfset scolor= "eeeeee">
        </form>
      </cfif>
</cfoutput>
<cfelse>
    <p>Não há cobranças a serem feitas</p>
  </cfif>
</table>
<form name="formx" method="post" action="EnvioEmailPesq.cfm">
  <input name="sninsp" type="hidden" id="sninsp">
  <input name="sacao" type="hidden" id="sacao">
</form>
<!--- Término da área de conteúdo --->
</body>
</html>

<cfprocessingdirective pageEncoding ="utf-8">
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>
<!DOCTYPE html>
<html lang="pt-BR">
   <head>
      <title>Sistema de Acompanhamento das Respostas das Inspeções</title>
      <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
   </head>

   <body>

            <table width="100%" border="0" cellpadding="0" cellspacing="0">
                  <cfinclude template="cabecalho.cfm">
            </table>
            <cfobject component = "CFC/tabs" name = "tabs">
            <div style="margin-top:10px;">
               <cfinvoke component="#tabs#" method="tabComponet" returnVariable="tabComponet"
                           listaNomeAbas=   "CONSULTAR <BR>PLANO DE TESTE,
                                             REPLICAR <BR>PLANO DE TESTE,
                                             CADASTRAR<br>GRUPO,
                                             CADASTRAR ITEM /<br>PLANO DE TESTE, 
                                             ALTERAR<br>GRUPOS,
                                             ALTERAR ITENS /<br>PLANO DE TESTE,
                                             ATIVAR ITENS /<br>PLANO DE TESTE"
                           listaPaginaInclude="cadastroGruposItens_consulta.cfm,cadastroGruposItens_replicar.cfm,cadastroGruposItens_cadGrupo.cfm,cadastroGruposItens_cadItem.cfm,cadastroGruposItens_alterarGrupo.cfm,cadastroGruposItens_alterarItem.cfm,cadastroGruposItens_ativarDesativar.cfm"
                           largura ="860"
                           titulo="CADASTRO DE GRUPOS E ITENS (PLANO DE TESTE)">
                           
            </div>
   </body>
</html>
<cfprocessingdirective pageEncoding ="utf-8"/>
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>
<cfoutput></cfoutput>
<!---verifica se a inspeção informada para exclusão possue itens com status diferente de 0-EM REVISAO, 11-EM LIBERACAO ou 14-NAO RESPONDIDO--->
<cfquery name="qVerificaStatus" datasource="#dsn_inspecao#">
    SELECT Pos_Inspecao FROM ParecerUnidade
    WHERE Pos_Unidade = '#sto#' AND Pos_Inspecao = '#nu_inspecao#' AND
          Pos_Situacao_Resp NOT IN (0,11,14) 
</cfquery>



<cfif qVerificaStatus.recordCount eq 0>
         <cfquery name="qAcesso" datasource="#dsn_inspecao#">
            select Usu_DR,Usu_GrupoAcesso, Usu_Matricula, Usu_Email, Usu_Apelido, Usu_Coordena from usuarios where Usu_login = (<cfqueryparam cfsqltype="cf_sql_varchar" value="#cgi.REMOTE_USER#">)
         </cfquery>
         <cfset CurrentPage=GetFileFromPath(GetTemplatePath())>

               <cfquery name="qAnexos" datasource="#dsn_inspecao#">
               SELECT     Ane_NumInspecao, Ane_Unidade, Ane_NumGrupo, Ane_NumItem, Ane_Codigo, Ane_Caminho
               FROM       Anexos
               WHERE  Ane_Unidade = '#sto#' and Ane_NumInspecao = '#nu_inspecao#'
            </cfquery>

         <cfif IsDefined("form.nu_inspecao") and form.nu_inspecao neq "">
            <cfquery datasource="#dsn_inspecao#">
            DELETE FROM Andamento WHERE AND_Unidade = '#sto#' and AND_NumInspecao = '#nu_inspecao#'
            </cfquery>
            <cfquery datasource="#dsn_inspecao#">
            DELETE FROM ParecerCausaProvavel WHERE PCP_Unidade = '#sto#' and PCP_Inspecao = '#nu_inspecao#'
            </cfquery>
            <cfquery datasource="#dsn_inspecao#">
            DELETE FROM ParecerUnidade WHERE Pos_Unidade = '#sto#' and Pos_Inspecao = '#nu_inspecao#'
            </cfquery>
            <cfquery datasource="#dsn_inspecao#">
            DELETE FROM ProcessoParecerUnidade WHERE Pro_Unidade = '#sto#' and Pro_Inspecao = '#nu_inspecao#'
            </cfquery>
            <cfquery datasource="#dsn_inspecao#">
            DELETE FROM Resultado_Inspecao WHERE RIP_Unidade = '#sto#' and RIP_NumInspecao = '#nu_inspecao#'
            </cfquery>
            <cfquery datasource="#dsn_inspecao#">
            DELETE FROM Inspetor_Inspecao WHERE IPT_CodUnidade = '#sto#' and IPT_NumInspecao = '#nu_inspecao#'
            </cfquery>
            <cfquery datasource="#dsn_inspecao#">
            DELETE FROM Inspecao WHERE INP_Unidade = '#sto#' and INP_NumInspecao = '#nu_inspecao#'
            </cfquery>
            <cfquery datasource="#dsn_inspecao#">
              UPDATE Numera_Inspecao SET NIP_Situacao ='E', NIP_DtUltAtu=convert(char,	getdate(), 120),  NIP_UserName=convert(varchar,'#qAcesso.Usu_Matricula#')
              WHERE NIP_NumInspecao=rtrim(ltrim(convert(varchar,'#nu_inspecao#'))) and NIP_Unidade=rtrim(ltrim('#sto#'))
            </cfquery>
         
            
            <cfquery datasource="#dsn_inspecao#">
            DELETE FROM Analise WHERE Ana_Unidade = '#sto#' and Ana_NumInspecao = '#nu_inspecao#'
            </cfquery>
            <cfif qAnexos.recordCount Neq 0>
               <cfif FileExists(qAnexos.Ane_Caminho)>
               <cffile action="delete" file="#qAnexos.Ane_Caminho#">
               </cfif>
               <cfquery datasource="#dsn_inspecao#">
                  DELETE FROM Anexos WHERE Ane_Unidade = '#sto#' and Ane_NumInspecao = '#nu_inspecao#'
               </cfquery>
            </cfif>
         </cfif>
         <html>
         <head>
         <title>Sistema de Acompanhamento das Respostas das Auditorias</title>
         <style type="text/css">
         <!--
         .style1 {
            color: FF0000;
            font-weight: bold;
         }
         -->
         </style>
         </head>
         <table>
         <body>
            <br><br><br><br><br><br><br>
            <div align="center" class="style1">Caro Usuário, sua operação de exclusão foi realizada com sucesso!!! </div><br><br>
            <tr><td  width="15%" align="center"><input type="button" class="botao"  onClick="history.back()" value="Voltar">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" class="botao" onClick="window.close()" value="Fechar"></td></tr>
         </table>
      </body>
      </html>
<cfelse>
       <html>
         <head>
         <title>Sistema de Acompanhamento das Respostas das Auditorias</title>
         <style type="text/css">
         <!--
         .style1 {
            color: rgb(163, 36, 36);
            font-weight: bold;
         }
         -->
         </style>
         </head>
         <table>
         <body>
            <br><br><br><br><br><br><br> 
            <div align="center" class="style1"><p style="font-size:25">Caro Usuário, exclusão não permitida!</p>
            <br> A Inspeção <cfoutput>N° #nu_inspecao#</cfoutput> possue, pelo menos, um item com status não permitido para exclusão.
            <br> Apenas inspeções com itens nos status EM REVISÃO, EM LIBERAÇÃO ou NÃO RESPONDIDO podem ser excluídas.
            </div><br><br>
            <tr><td  width="15%" align="center"><input type="button" class="botao"  onClick="history.back()" value="Voltar">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" class="botao" onClick="window.close()" value="Fechar"></td></tr>
         </table>
      </body>
      </html>

</cfif>


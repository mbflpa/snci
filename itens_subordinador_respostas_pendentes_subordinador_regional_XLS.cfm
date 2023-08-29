<cfprocessingdirective pageEncoding ="utf-8"/>

 <html>
      <head>
             <title>Sistema Nacional de Controle Interno</title>
             <link href="CSS.css" rel="stylesheet" type="text/css">
             <meta http-equiv="Content-Type" content="text/html; charset=utf-8">

      </head>
<body>
   <p>Aguarde...</p>
</body>
 
 
 <cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False')>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>  

<cfif isDefined("Session.E01")>
   <cfset StructClear(Session.E01)> 
</cfif>



            <cfquery name="qAcesso" datasource="#dsn_inspecao#">
                  select Usu_GrupoAcesso, Usu_Lotacao, Usu_DR from usuarios where Usu_login = '#cgi.REMOTE_USER#'
            </cfquery>


                  <cfquery name="qArea" datasource="#dsn_inspecao#">
                        SELECT Ars_Codigo, Ars_Sigla, Ars_Descricao FROM Areas WHERE Ars_Codigo='#qAcesso.Usu_Lotacao#' AND Ars_Status ='A'
                  </cfquery>
                  <cfset dataInicio = '#dtinicial#'>
            <cfset dataFim = '#dtfinal#'>
                  
                  <cfif dtinicial neq '' and dtfinal neq ''> 
                  <cfset dataInicio = createdate(right(dtinicial,4), mid(dtinicial,4,2), left(dtinicial,2))>
                  <cfset dataFim = createdate(right(dtfinal,4), mid(dtfinal,4,2), left(dtfinal,2))>     
            </cfif>
                              
                  

            <cfquery name="rsXLS" datasource="#dsn_inspecao#" >
            
                  <cfif ckTipo eq "1">
						SELECT CASE WHEN INP_Modalidade = 0 then 'Fisica' else 'Remota' end as INPModal, RIP_ReincInspecao as RIPRInsp, convert(char, RIP_ReincGrupo) as RIPRGp, convert(char, RIP_ReincItem) as RIPRIt, Und_CodDiretoria, Pos_Unidade, Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Und_CodReop, RIP_Ano, RIP_Resposta, substring(RIP_Comentario,1,32500) as comentario, RIP_Caractvlr, RIP_Falta, RIP_Sobra, RIP_EmRisco, convert(char,RIP_DtUltAtu,120) as RIPDtUltAtu, case when left(POS_UserName,8) = 'EXTRANET' then concat(left(pos_username,9),'***',substring(trim(pos_username),12,8)) else concat(left(trim(pos_username),12),substring(trim(pos_username),13,4),'***',right(trim(pos_username),1)) end as posusername, RIP_Recomendacao, INP_HrsPreInspecao, convert(char,INP_DtInicDeslocamento,103) as INPDtInicDesloc, INP_HrsDeslocamento, convert(char,INP_DtFimDeslocamento,103) as INPDtFimDesloc, convert(char,INP_DtInicInspecao,103) as INPDtInicInsp, convert(char,INP_DtFimInspecao,103) as INPDtFimInsp, INP_HrsInspecao, INP_Situacao, convert(char,INP_DtEncerramento,103) as INPDtEncer, concat(left(INP_Coordenador,1),'.',substring(INP_Coordenador,2,3),'.***-',right(INP_Coordenador,1)) as INPCoordenador, INP_Responsavel, substring(INP_Motivo,1,32500) as motivo, Pos_Situacao_Resp, STO_Sigla, STO_Descricao, convert(char,Pos_DtPosic,103) as PosDtPosic, convert(char,Pos_DtPrev_Solucao,103) as PosDtPrevSoluc, Pos_Area, Pos_NomeArea, substring(Pos_Parecer,1,32500) as parecer, Pos_VLRecuperado, Pos_Processo, Pos_Tipo_Processo, Grp_Descricao, Itn_Descricao, Pos_SEI, DATEDIFF(dd, Pos_DtPosic, GETDATE()) AS Quant, 
						CASE WHEN Pos_OpcaoBaixa = 1 then 'Penalidade Aplicada' WHEN Pos_OpcaoBaixa = 2 then 'Defesa Acatada'  WHEN Pos_OpcaoBaixa = 3 then 'Outros' end as Pos_OpcaoBaixa, case when LTRIM(RTRIM(SEI_NumSEI)) IS NULL AND Pos_OpcaoBaixa IS NOT NULL then 'não informado' else LEFT(SEI_NumSEI,5)+'.'+SUBSTRING(SEI_NumSEI,6,6)+'/'+SUBSTRING(SEI_NumSEI,12,4) +'-'+RIGHT(SEI_NumSEI,2) end AS SEI_NumSEI
						FROM Reops 
						INNER JOIN Resultado_Inspecao 
						INNER JOIN Grupos_Verificacao 
						INNER JOIN Unidades 
						INNER JOIN ParecerUnidade 
						INNER JOIN Inspecao ON Pos_Unidade = INP_Unidade AND Pos_Inspecao = INP_NumInspecao 
						ON Und_Codigo = Pos_Unidade 
						ON Grp_Codigo = Pos_NumGrupo 
						ON RIP_Unidade = Pos_Unidade AND RIP_NumInspecao = INP_NumInspecao AND RIP_NumInspecao = Pos_Inspecao AND 
						RIP_NumGrupo = Pos_NumGrupo AND RIP_NumItem = Pos_NumItem 
						ON Rep_Codigo = RIP_CodReop 
						INNER JOIN Itens_Verificacao 
						ON Itn_Ano = convert(char(4), RIP_Ano) and Grp_Ano = Itn_Ano and Itn_NumGrupo = Pos_NumGrupo AND Pos_NumItem = Itn_NumItem 
						and (Itn_TipoUnidade = Und_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade)
						INNER JOIN Situacao_Ponto ON Pos_Situacao_Resp = STO_Codigo
						LEFT JOIN Inspecao_SEI ON  SEI_Inspecao= Pos_Inspecao AND SEI_Grupo = Pos_NumGrupo AND SEI_Item = Pos_NumItem AND SEI_Unidade = Pos_Unidade     
						WHERE  (pos_situacao_resp in (4,5,19,21)) and (pos_area='#qAcesso.Usu_Lotacao#')    
						ORDER BY Und_Descricao, Pos_NumGrupo, Pos_NumItem, Pos_Inspecao, Quant
                  <cfelse> 
						SELECT CASE WHEN INP_Modalidade = 0 then 'Fisica' else 'Remota' end as INPModal, RIP_ReincInspecao as RIPRInsp, convert(char, RIP_ReincGrupo) as RIPRGp, convert(char, RIP_ReincItem) as RIPRIt, Unidades.Und_CodDiretoria, Pos_Unidade, Unidades.Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, Unidades.Und_CodReop, RIP_Ano, RIP_Resposta, substring(RIP_Comentario,1,32500) as comentario, RIP_Caractvlr, RIP_Falta, RIP_Sobra, RIP_EmRisco, convert(char,RIP_DtUltAtu,120) as RIPDtUltAtu, case when left(POS_UserName,8) = 'EXTRANET' then concat(left(POS_UserName,9),'***',substring(trim(POS_UserName),12,8)) else concat(left(trim(POS_UserName),12),substring(trim(POS_UserName),13,4),'***',right(trim(POS_UserName),1)) end as POSUserName, RIP_Recomendacao, INP_HrsPreInspecao, convert(char,INP_DtInicDeslocamento,103) as INPDtInicDesloc, INP_HrsDeslocamento, convert(char,INP_DtFimDeslocamento,103) as INPDtFimDesloc, convert(char,INP_DtInicInspecao,103) as INPDtInicInsp, convert(char,INP_DtFimInspecao,103) as INPDtFimInsp, INP_HrsInspecao, INP_Situacao, convert(char,INP_DtEncerramento,103) as INPDtEncer, concat(left(INP_Coordenador,1),'.',substring(INP_Coordenador,2,3),'.***-',right(INP_Coordenador,1)) as INPCoordenador, INP_Responsavel, substring(INP_Motivo,1,32500) as motivo, Pos_Situacao_Resp, STO_Sigla, STO_Descricao, convert(char,Pos_DtPosic,103) as PosDtPosic, convert(char,Pos_DtPrev_Solucao,103) as PosDtPrevSoluc, Pos_Area, Pos_NomeArea, substring(Pos_Parecer,1,32500) as parecer, Pos_VLRecuperado, Pos_Processo, Pos_Tipo_Processo, Grp_Descricao, Itn_Descricao, Pos_SEI, DATEDIFF(dd, Pos_DtPosic, GETDATE()) AS Quant, 
						CASE WHEN Pos_OpcaoBaixa = 1 then 'Penalidade Aplicada' WHEN Pos_OpcaoBaixa = 2 then 'Defesa Acatada'  WHEN Pos_OpcaoBaixa = 3 then 'Outros' end as Pos_OpcaoBaixa, case when LTRIM(RTRIM(SEI_NumSEI)) IS NULL AND Pos_OpcaoBaixa IS NOT NULL then 'não informado' else LEFT(SEI_NumSEI,5)+'.'+SUBSTRING(SEI_NumSEI,6,6)+'/'+SUBSTRING(SEI_NumSEI,12,4) +'-'+RIGHT(SEI_NumSEI,2) end AS SEI_NumSEI 
						
						FROM Resultado_Inspecao 
						INNER JOIN ((((((Inspecao 
						INNER JOIN (ParecerUnidade 
						INNER JOIN Unidades 
						ON ParecerUnidade.Pos_Unidade = Unidades.Und_Codigo) 
						ON (Inspecao.INP_NumInspecao = ParecerUnidade.Pos_Inspecao) 
						AND (Inspecao.INP_Unidade = ParecerUnidade.Pos_Unidade)) 
						INNER JOIN (Itens_Verificacao 
						INNER JOIN Grupos_Verificacao 
						ON Itn_NumGrupo = Grp_Codigo and Grp_Ano = Itn_Ano) 
						ON (ParecerUnidade.Pos_NumItem = Itens_Verificacao.Itn_NumItem) AND (ParecerUnidade.Pos_NumGrupo = Itens_Verificacao.Itn_NumGrupo)
						AND  right(Pos_Inspecao,4) = Itn_Ano and (Itn_TipoUnidade = Und_TipoUnidade) AND (INP_Modalidade = Itn_Modalidade)) 
						INNER JOIN Situacao_Ponto 
						ON ParecerUnidade.Pos_Situacao_Resp = Situacao_Ponto.STO_Codigo) 
						LEFT JOIN Reops 
						ON ParecerUnidade.Pos_Area = Reops.Rep_Codigo) 
						LEFT JOIN Unidades AS Unidades_1 
						ON ParecerUnidade.Pos_Area = Unidades_1.Und_Codigo) 
						LEFT JOIN Reops    AS Reops_1 
						ON Unidades_1.Und_CodReop = Reops_1.Rep_Codigo) 
						ON (Resultado_Inspecao.RIP_NumItem = ParecerUnidade.Pos_NumItem) 
						AND (Resultado_Inspecao.RIP_NumGrupo = ParecerUnidade.Pos_NumGrupo) 
						AND (Resultado_Inspecao.RIP_NumInspecao = ParecerUnidade.Pos_Inspecao) 
						AND (Resultado_Inspecao.RIP_Unidade = ParecerUnidade.Pos_Unidade) 
						LEFT JOIN Reops    AS Reops_2 
						ON Unidades.Und_CodReop = Reops_2.Rep_Codigo  
						LEFT JOIN Inspecao_SEI ON  SEI_Inspecao= Pos_Inspecao AND SEI_Grupo= Pos_NumGrupo AND  SEI_Item = Pos_NumItem AND SEI_Unidade = Pos_Unidade

                                          <cfif  '#frmResp#' neq '' >
                              <cfswitch expression='#frmResp#'>
                                    <cfcase value="N">WHERE  (Reops.Rep_CodArea='#qAcesso.Usu_Lotacao#' OR Reops_1.Rep_CodArea='#qAcesso.Usu_Lotacao#' OR Pos_Area = '#qAcesso.Usu_Lotacao#') AND pos_situacao_resp in (2,4,5,14,15,16,19) </cfcase>
                                    <cfcase value="S">WHERE  (Reops.Rep_CodArea='#qAcesso.Usu_Lotacao#' OR Reops_1.Rep_CodArea='#qAcesso.Usu_Lotacao#' OR Pos_Area = '#qAcesso.Usu_Lotacao#') AND pos_situacao_resp in (3) </cfcase>
                                    <cfcase value="A">WHERE  (Reops.Rep_CodArea='#qAcesso.Usu_Lotacao#' OR Reops_1.Rep_CodArea='#qAcesso.Usu_Lotacao#' OR Reops_2.Rep_CodArea='#qAcesso.Usu_Lotacao#' OR Pos_Area = '#qAcesso.Usu_Lotacao#') AND pos_situacao_resp in (24) </cfcase>
                                    <cfcase value="R">WHERE  (Reops.Rep_CodArea='#qAcesso.Usu_Lotacao#' OR Reops_1.Rep_CodArea='#qAcesso.Usu_Lotacao#' OR Reops_2.Rep_CodArea='#qAcesso.Usu_Lotacao#' OR Pos_Area = '#qAcesso.Usu_Lotacao#') AND pos_situacao_resp in (14,18,20,25,26,27) AND Unidades.Und_TipoUnidade IN (12,16)</cfcase>
                                    <cfcase value="C">WHERE  (Reops.Rep_CodArea='#qAcesso.Usu_Lotacao#' OR Reops_1.Rep_CodArea='#qAcesso.Usu_Lotacao#' OR Reops_2.Rep_CodArea='#qAcesso.Usu_Lotacao#' OR Pos_Area = '#qAcesso.Usu_Lotacao#') AND pos_situacao_resp in (9) </cfcase>
									<cfcase value="E">WHERE  (Reops.Rep_CodArea='#qAcesso.Usu_Lotacao#' OR Reops_1.Rep_CodArea='#qAcesso.Usu_Lotacao#' OR Reops_2.Rep_CodArea='#qAcesso.Usu_Lotacao#' OR Pos_Area = '#qAcesso.Usu_Lotacao#') AND pos_situacao_resp in (29) </cfcase>
                              </cfswitch>
                        </cfif>
                        <cfif  '#dataInicio#' neq '' and '#dataFim#' neq ''> 
                                    AND (INP_DtFimInspecao BETWEEN #dataInicio# AND #dataFim#)
                        </cfif>  
                              
                        ORDER BY Und_Descricao, Pos_NumGrupo, Pos_NumItem, Pos_Inspecao, Quant
                  </cfif>
            </cfquery>

            
            <cfoutput>
            <cfquery name="qUsuario" datasource="#dsn_inspecao#">
                  SELECT DISTINCT Usu_Matricula FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
            </cfquery>
            </cfoutput>
            <!--- Excluir arquivos anteriores ao dia atual --->
            <cfset sdata = dateformat(now(),"YYYYMMDDHH")>
            <cfset diretorio =#GetDirectoryFromPath(GetTemplatePath())#>
            <cfset slocal = #diretorio# & 'Fechamento\'>

            <cfoutput>
            <cfset sarquivo = #DateFormat(now(),"YYYYMMDDHH")# & '_' & #trim(qUsuario.Usu_Matricula)# & '.xls'>
            </cfoutput>

            <cfdirectory name="qList" filter="*.*" sort="name desc" directory="#slocal#">
                  <cfoutput query="qList">
                        <cfif len(name) eq 23>
                              <cfif (left(name,8) lt left(sdata,8)) or (int(mid(sdata,9,2) - mid(name,9,2)) gte 2)>
                              <cffile action="delete" file="#slocal##name#">
                              </cfif>
                        </cfif>
                  </cfoutput>
            <!--- fim exclusão --->

            <cfif Month(Now()) eq 1>
                  <cfset vANO = Year(Now()) - 1>
            <cfelse>
                  <cfset vANO = Year(Now())>
            </cfif>

            <cfset objPOI = CreateObject(
                  "component",
                  "Excel"
                  ).Init()
                  />

            <cfset data = now() - 1>


            <cfset objPOI.WriteSingleExcel(
                  FilePath = ExpandPath( "./Fechamento/" & sarquivo ),
                  Query = rsXLS,
                  ColumnList = "INPModal,Und_CodDiretoria,Pos_Unidade,Und_Descricao,Pos_Inspecao,Pos_NumGrupo,Grp_Descricao,Pos_NumItem,Itn_Descricao,Und_CodReop,RIP_Ano,RIP_Resposta,RIP_Caractvlr,RIP_Falta,RIP_Sobra,RIP_EmRisco,RIPDtUltAtu,POSUserName,RIP_Recomendacao,INP_HrsPreInspecao,INPDtInicDesloc,INP_HrsDeslocamento,INPDtFimDesloc,INPDtInicInsp,INPDtFimInsp,INP_HrsInspecao,INP_Situacao,INPDtEncer,INPCoordenador,INP_Responsavel,motivo,Pos_Situacao_Resp,STO_Sigla,STO_Descricao,PosDtPosic,PosDtPrevSoluc,Pos_Area,Pos_NomeArea,parecer,Pos_VLRecuperado,Pos_Processo,Pos_Tipo_Processo,Pos_SEI,RIPRInsp,RIPRGp,RIPRIt,Quant,Pos_OpcaoBaixa,SEI_NumSEI",
                  ColumnNames = "Modalidade,Diretoria,Código Unidade Inspecionada,Unidade Inspecionada,Nº Inspeção,Nº Grupo,Descrição do Grupo,Nº Item,Descrição Item,Código REATE,ANO,Resposta,CaracteresVlr,Falta,Sobra,EmRisco,DtUltAtu,Nome do Usuário,Recomendação,Hora Pré Inspeção,DT_Inic Desloc,Hora Desloc,DT_Fim Desloc,DT_Inic Inspeção,DT_Fim Inspecao,Hora Inspecao,Situação,DT_Encerram,Coordenador,Responsável,Motivo,Status,Sigla do Status,Descrição do Status,DT_Posição,Data Previsão Solução,Código Órgão Condutor,Órgão Condutor,Parecer,Valor Recuperado,Processo,Tipo_Processo,SEI,ReInc_Relat,ReInc_Grupo,ReInc_Item,Qtd_Dias,OpcaoDeBaixa,SEI_Baixa",
                  SheetName = "SubordinadorRegional"
                  ) />

      <script type="text/javascript">

            window.onload = function () {   
                  window.open('','_parent',''); 
                  window.open('Fechamento/<cfoutput>#sarquivo#</cfoutput>');
                  window.close();
            }
      
      </script>
 
 
</html>


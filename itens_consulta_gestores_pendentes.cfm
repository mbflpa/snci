<cfprocessingdirective pageEncoding ="utf-8"/>
<cfif (not isDefined("Session.vPermissao")) OR (Session.vPermissao eq 'False' )>
  <cfinclude template="aviso_sessao_encerrada.htm">
	  <cfabort> 
</cfif>


<cfif isDefined("Session.E01")>
  <cfset StructClear(Session.E01)>
</cfif>


<!--- <cfquery name="situacoes" datasource="#dsn_inspecao#">
  Select STO_Cor, STO_Codigo, STO_Sigla, STO_Descricao, STO_Conceito from Situacao_ponto where STO_Status = 'A'
  </cfquery>
   <cfoutput query="situacoes" >
    <table width="100%" class="exibir">
    <tr>
                                       <td bgcolor="#STO_Cor#">
                                        <div align="center"><strong>#trim(STO_Descricao)#</strong>
                                        </div>
                                      </td>
                                      <td >
                                        <div align="center">#STO_Codigo#</div>
                                      </td>
                                      <td >
                                        <div align="center">#STO_Sigla#</div>
                                      </td>
                                      <td >
                                        <div align="center">#STO_Conceito#</div>
                                      </td>
                                    </tr>
  </cfoutput>
  </table> --->


<cfquery name="qAcesso" datasource="#dsn_inspecao#">
  select Usu_GrupoAcesso, Usu_Lotacao, Usu_DR, Dir_Descricao from usuarios 
  INNER JOIN Diretoria ON Diretoria.Dir_Codigo = Usu_DR
  where Usu_login = '#cgi.REMOTE_USER#'
</cfquery>

<cfquery name="rsDEPTO" datasource="#dsn_inspecao#">
  SELECT Dep_Sigla, Dep_Descricao FROM Departamento WHERE Dep_Codigo='#qAcesso.Usu_Lotacao#'
</cfquery>

<cfif isDefined("frmSE")>
  <cfset se='#frmSE#'>
  <cfquery name="rsSE" datasource="#dsn_inspecao#">
    SELECT Dir_Sigla FROM Diretoria WHERE Dir_Codigo=#se#
  </cfquery>
  <cfset seSigla='#trim(rsSE.Dir_Sigla)#'>
  <cfset sigla='TODAS AS UNIDADES SUBORDINADAS AO  #rsDEPTO.Dep_Descricao# NA SE/#seSigla#'>
<cfelse>
  <cfset se=''>
  <cfset sigla='TODAS AS UNIDADES SUBORDINADAS AO  #rsDEPTO.Dep_Descricao#' & '<br>' & '(Todas as Superintendências Estaduais)'>
</cfif>



<cfif Trim(qAcesso.Usu_GrupoAcesso) eq 'DEPARTAMENTO' or Trim(qAcesso.Usu_GrupoAcesso) eq 'DESENVOLVEDORES'>


      <cfquery name="rsItem" datasource="#dsn_inspecao#">
      SELECT     Unidades.Und_CodDiretoria,                  
                INP_DtInicInspecao,                   
                Pos_NumItem,                         
                Pos_Unidade,                         
                DATEDIFF(dd, Pos_DtPosic, GETDATE()) AS Quant,
                Unidades.Und_Descricao,               
                Unidades.Und_TipoUnidade,            
                Pos_Inspecao,                        
                Pos_NumGrupo,                         
                Pos_dtultatu,                        
                Itn_Descricao,                       
                Grp_Descricao,                       
                Pos_Situacao_Resp,                    
                RIP_NumInspecao,                      
                Pos_Parecer,                         
                pos_area,                             
                INP_DtInicInspecao,                   
                INP_DtFimInspecao,                    
                INP_DtEncerramento,                  
                STO_Codigo,                          
                STO_Sigla,                           
                STO_Cor,                            
                STO_Descricao                      
           FROM Resultado_Inspecao 
     INNER JOIN ParecerUnidade 
             ON RIP_NumItem = Pos_NumItem 
                AND RIP_NumGrupo = Pos_NumGrupo 
                AND RIP_NumInspecao = Pos_Inspecao 
                AND RIP_Unidade = Pos_Unidade  
     INNER JOIN Unidades 
             ON ParecerUnidade.Pos_Unidade = Unidades.Und_Codigo
     INNER JOIN Itens_Verificacao 
     INNER JOIN Grupos_Verificacao 
             ON Itn_NumGrupo = Grp_Codigo 
             ON Pos_NumItem = Itn_NumItem 
                AND Pos_NumGrupo = Itn_NumGrupo 
                AND Grp_Ano = Itn_Ano AND convert(char(4), Rip_ano) = Itn_Ano
     INNER JOIN Inspecao 
             ON Pos_Inspecao = INP_NumInspecao 
                AND Pos_Unidade = INP_Unidade and (Itn_Modalidade = INP_Modalidade) and (Itn_TipoUnidade = Und_TipoUnidade)
				INNER JOIN Situacao_Ponto 
             ON Pos_Situacao_Resp = STO_Codigo

         <cfif '#frmResp#' neq ''> 
           <cfswitch expression='#frmResp#'>
             <cfcase value="N">WHERE pos_situacao_resp in (2,4,5,8,14,15,16,19,23) </cfcase>
             <cfcase value="S">WHERE pos_situacao_resp in (3) </cfcase>
             <cfcase value="A">WHERE pos_situacao_resp in (24) </cfcase>
             <cfcase value="R">WHERE pos_situacao_resp in (14,18,20,25,26,27) AND Unidades.Und_TipoUnidade=12 </cfcase>
             <cfcase value="C">WHERE pos_situacao_resp in (9) </cfcase>
           </cfswitch>

           <cfif isDefined("frmSE")>
                AND Unidades.Und_CodDiretoria= #se#
           </cfif>

            <cfif find("DERAT", rsDEPTO.Dep_Sigla) gt 0>
                AND (Und_TipoUnidade=9 Or Und_TipoUnidade=12 Or Und_TipoUnidade=16 Or Und_TipoUnidade=20)
            <cfelseif find("DEDIS", rsDEPTO.Dep_Sigla) gt 0>
                AND (Und_TipoUnidade=4 Or Und_TipoUnidade=7 Or Und_TipoUnidade=29)
			<cfelseif find("DELOG", rsDEPTO.Dep_Sigla) gt 0>
                AND (Und_TipoUnidade=24 Or Und_TipoUnidade=25 Or Und_TipoUnidade=26 Or Und_TipoUnidade=27 Or Und_TipoUnidade=28 Or Und_TipoUnidade=30)	
            <cfelseif find("DTRAT", rsDEPTO.Dep_Sigla) gt 0>
                AND (Und_TipoUnidade=5 Or Und_TipoUnidade=6 Or Und_TipoUnidade=8 or Und_TipoUnidade=21 or Und_TipoUnidade=22 or Und_TipoUnidade=23)
            </cfif>

         </cfif>
         <cfset dataInicio='#dtinicial#'>
         <cfset dataFim='#dtfinal#'>

         <cfif dtinicial neq '' and dtfinal neq ''>
           <cfset dataInicio=createdate(right(dtinicial,4), mid(dtinicial,4,2), left(dtinicial,2))>
           <cfset dataFim=createdate(right(dtfinal,4), mid(dtfinal,4,2), left(dtfinal,2))>
         </cfif>

         <cfif '#dataInicio#' neq '' and '#dataFim#' neq ''>
           AND (INP_DtFimInspecao BETWEEN #dataInicio# AND #dataFim#)
         </cfif>
     
           ORDER BY Unidades.Und_CodDiretoria, Und_Descricao, Pos_NumGrupo, Pos_NumItem, Pos_Inspecao, Quant
         
      </cfquery>

      <cfquery name="rsXLS" datasource="#dsn_inspecao#">
        SELECT CASE WHEN INP_Modalidade = 0 then 'Fisica' else 'Remota' end as INPModal, RIP_ReincInspecao as RIPRInsp,
        convert(char, RIP_ReincGrupo) as RIPRGp, convert(char, RIP_ReincItem) as RIPRIt, Und_CodDiretoria, Pos_Unidade,
        Und_Descricao, Pos_Inspecao, Pos_NumGrupo, Pos_NumItem, RIP_Ano, RIP_Resposta, RIP_Caractvlr, convert(money, RIP_Falta) as RIPFalta, convert(money, RIP_Sobra) as RIPSobra, convert(money, RIP_EmRisco) as RIPEmRisco, 
		convert(char,Pos_DtUltAtu,120) as POSDtUltAtu, case when left(POS_UserName,8) = 'EXTRANET' then concat(left(POS_UserName,9),'***',substring(trim(POS_UserName),12,8)) else concat(left(trim(POS_UserName),12),substring(trim(POS_UserName),13,4),'***',right(trim(POS_UserName),1)) end as POSUserName, RIP_Recomendacao, INP_HrsPreInspecao,
        convert(char,INP_DtInicDeslocamento,103) as INPDtInicDesloc, INP_HrsDeslocamento,
        convert(char,INP_DtFimDeslocamento,103) as INPDtFimDesloc, convert(char,INP_DtInicInspecao,103) as
        INPDtInicInsp, convert(char,INP_DtFimInspecao,103) as INPDtFimInsp, INP_HrsInspecao, INP_Situacao,
        convert(char,INP_DtEncerramento,103) as INPDtEncer, concat(left(INP_Coordenador,1),'.',substring(INP_Coordenador,2,3),'.***-',right(INP_Coordenador,1)) as INPCoordenador, INP_Responsavel,
        substring(INP_Motivo,1,32500) as motivo, Pos_Situacao_Resp, STO_Sigla, STO_Descricao,
        convert(char,Pos_DtPosic,103) as PosDtPosic, convert(char,Pos_DtPrev_Solucao,103) as PosDtPrevSoluc, Pos_Area,
        Pos_NomeArea, substring(Pos_Parecer,1,32500) as parecer, Pos_VLRecuperado, Pos_Processo, Pos_Tipo_Processo,
        Grp_Descricao, Itn_Descricao, Pos_SEI, DATEDIFF(dd, Pos_DtPosic, GETDATE()) AS Quant
        FROM Resultado_Inspecao 
     INNER JOIN ParecerUnidade 
             ON RIP_NumItem = Pos_NumItem 
                AND RIP_NumGrupo = Pos_NumGrupo 
                AND RIP_NumInspecao = Pos_Inspecao 
                AND RIP_Unidade = Pos_Unidade  
     INNER JOIN Unidades 
             ON ParecerUnidade.Pos_Unidade = Unidades.Und_Codigo
     INNER JOIN Itens_Verificacao 
     INNER JOIN Grupos_Verificacao 
             ON Itn_NumGrupo = Grp_Codigo 
             ON Pos_NumItem = Itn_NumItem 
                AND Pos_NumGrupo = Itn_NumGrupo 
                AND Grp_Ano = Itn_Ano AND convert(char(4), Rip_ano) = Itn_Ano
     INNER JOIN Inspecao 
             ON Pos_Inspecao = INP_NumInspecao 
                AND Pos_Unidade = INP_Unidade and (Itn_Modalidade = INP_Modalidade) and (Itn_TipoUnidade = Und_TipoUnidade)
				INNER JOIN Situacao_Ponto 
             ON Pos_Situacao_Resp = STO_Codigo
             <cfif '#frmResp#' neq ''> 
           <cfswitch expression='#frmResp#'>
             <cfcase value="N">WHERE pos_situacao_resp in (2,4,5,8,14,15,16,19,23) </cfcase>
             <cfcase value="S">WHERE pos_situacao_resp in (3) </cfcase>
             <cfcase value="A">WHERE pos_situacao_resp in (24) </cfcase>
             <cfcase value="R">WHERE pos_situacao_resp in (14,18,20,25,26,27) AND Unidades.Und_TipoUnidade=12 </cfcase>
             <cfcase value="C">WHERE pos_situacao_resp in (9) </cfcase>
           </cfswitch>

           <cfif isDefined("frmSE")>
                AND Unidades.Und_CodDiretoria= #se#
           </cfif>

            <cfif find("DERAT", rsDEPTO.Dep_Sigla) gt 0>
                AND (Und_TipoUnidade=9 Or Und_TipoUnidade=12 Or Und_TipoUnidade=16 Or Und_TipoUnidade=20)
            <cfelseif find("DEDIS", rsDEPTO.Dep_Sigla) gt 0>
                AND (Und_TipoUnidade=4 Or Und_TipoUnidade=29)
            <cfelseif find("DTRAT", rsDEPTO.Dep_Sigla) gt 0>
                AND (Und_TipoUnidade=5 Or Und_TipoUnidade=6 Or Und_TipoUnidade=8 or Und_TipoUnidade=21 or Und_TipoUnidade=22 or Und_TipoUnidade=23)
            </cfif>

         </cfif>
         <cfset dataInicio='#dtinicial#'>
         <cfset dataFim='#dtfinal#'>

         <cfif dtinicial neq '' and dtfinal neq ''>
           <cfset dataInicio=createdate(right(dtinicial,4), mid(dtinicial,4,2), left(dtinicial,2))>
           <cfset dataFim=createdate(right(dtfinal,4), mid(dtfinal,4,2), left(dtfinal,2))>
         </cfif>

         <cfif '#dataInicio#' neq '' and '#dataFim#' neq ''>
           AND (INP_DtFimInspecao BETWEEN #dataInicio# AND #dataFim#)
         </cfif>
 

         ORDER BY Unidades.Und_CodDiretoria, Und_Descricao, Pos_NumGrupo, Pos_NumItem, Pos_Inspecao, Quant
      </cfquery>

      <html>

      <head>
        <title>Sistema Nacional de Controle Interno</title>
        <link href="CSS.css" rel="stylesheet" type="text/css">
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <style type="text/css">
          <!--
          .style5 {
            font-size: 14;
            font-weight: bold;
          }
          -->
        </style>
        <link href="css.css" rel="stylesheet" type="text/css">
        <style type="text/css">
          <!--
          .style6 {
            color: #FF0000
          }
          -->
        </style>
        <cfquery name="rsSPnt" datasource="#dsn_inspecao#">
          SELECT STO_Codigo, STO_Sigla, STO_Cor, STO_Conceito FROM Situacao_Ponto where sto_status = 'A'
        </cfquery>
        <cfoutput query="rsSPnt">
          <div id="#rsSPnt.STO_Sigla#"
            style="position:absolute; z-index:1; visibility: hidden; background-color: FFFF00; layer-background-color: 000000; border: 1px none 000000; left: 52px; top: 16px;">
            <font size="1" face="Verdana" color="000000">#rsSPnt.STO_Conceito#</font>
          </div>
        </cfoutput>
      </head>

      <body>
        <script language="JavaScript">
          //detectando navegador
          sAgent = navigator.userAgent;
          bIsIE = sAgent.indexOf("MSIE") > -1;
          bIsNav = sAgent.indexOf("Mozilla") > -1 && !bIsIE;

          //setando as variaveis de controle de eventos do mouse
          var xmouse = 0;
          var ymouse = 0;
          document.onmousemove = MouseMove;

          //funcoes de controle de eventos do mouse:
          function MouseMove(e) {
            if (e) {
              MousePos(e);
            } else {
              MousePos();
            }
          }

          function MousePos(e) {
            if (bIsNav) {
              xmouse = e.pageX;
              ymouse = e.pageY;
            }
            if (bIsIE) {
              xmouse = document.body.scrollLeft + event.x;
              ymouse = document.body.scrollTop + event.y;
            }
          }

          //funcao que mostra e esconde o hint
          function Hint(objNome, action) {
            //action = 1 -> Esconder
            //action = 2 -> Mover

            if (bIsIE) {
              objHint = document.all[objNome];
            }
            if (bIsNav) {
              objHint = document.getElementById(objNome);
              event = objHint;
            }

            switch (action) {
              case 1: //Esconder
                objHint.style.visibility = "hidden";
                break;
              case 2: //Mover
                objHint.style.visibility = "visible";
                objHint.style.left = xmouse + 15;
                objHint.style.top = ymouse + 15;
                break;
            }

          }
        </script>
        <cfoutput>
          <cfquery name="qUsuario" datasource="#dsn_inspecao#">
            SELECT DISTINCT Usu_Matricula FROM Usuarios WHERE Usu_Login = '#CGI.REMOTE_USER#'
          </cfquery>
        </cfoutput>
        <!--- Excluir arquivos anteriores ao dia atual --->
        <cfset sdata=dateformat(now(),"YYYYMMDDHH")>
          <cfset diretorio=#GetDirectoryFromPath(GetTemplatePath())#>
            <cfset slocal=#diretorio# & 'Fechamento\'>

              <cfoutput>
                <cfset sarquivo=#DateFormat(now(),"YYYYMMDDHH")# & '_' & #trim(qUsuario.Usu_Matricula)# & '.xls'>
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

                <!--- <cftry> --->

                <cfif Month(Now()) eq 1>
                  <cfset vANO=Year(Now()) - 1>
                    <cfelse>
                      <cfset vANO=Year(Now())>
                </cfif>

                <cfset objPOI=CreateObject( "component" , "Excel" ).Init() />

                <cfset data=now() - 1>
                  <cfset objPOI.WriteSingleExcel( FilePath=ExpandPath( "./Fechamento/" & sarquivo ), Query=rsXLS,
                    ColumnList="INPModal,Und_CodDiretoria,Pos_Unidade,Und_Descricao,Pos_Inspecao,Pos_NumGrupo,Grp_Descricao,Pos_NumItem,Itn_Descricao,RIP_Ano,RIP_Resposta,RIP_Caractvlr,RIPFalta,RIPSobra,RIPEmRisco,POSDtUltAtu,POSUserName,RIP_Recomendacao,INP_HrsPreInspecao,INPDtInicDesloc,INP_HrsDeslocamento,INPDtFimDesloc,INPDtInicInsp,INPDtFimInsp,INP_HrsInspecao,INP_Situacao,INPDtEncer,INPCoordenador,INP_Responsavel,motivo,Pos_Situacao_Resp,STO_Sigla,STO_Descricao,PosDtPosic,PosDtPrevSoluc,Pos_Area,Pos_NomeArea,parecer,Pos_VLRecuperado,Pos_Processo,Pos_Tipo_Processo,Pos_SEI,RIPRInsp,RIPRGp,RIPRIt,Quant"
                    ,
                    ColumnNames="Modalidade,Superintendência,Código Unidade Inspecionada,Unidade Inspecionada,Nº Inspeção,Nº Grupo,Descrição do Grupo,Nº Item,Descrição Item,Código REATE,ANO,Resposta,CaracteresVlr,Falta,Sobra,EmRisco,DtUltAtu,Nome do Usuário,Recomendação,Hora Pré Inspeção,DT_Inic Desloc,Hora Desloc,DT_Fim Desloc,DT_Inic Inspeção,DT_Fim Inspecao,Hora Inspecao,Situação,DT_Encerram,Coordenador,Responsável,Motivo,Status,Sigla do Status,Descrição do Status,DT_Posição,Data Previsão Solução,Código Órgão Condutor,Órgão Condutor,Parecer,Valor Recuperado,Processo,Tipo_Processo,SEI,ReInc_Relat,ReInc_Grupo,ReInc_Item,Qtd_Dias"
                    , SheetName="SubordinadorRegional" ) />

                  <!--- <cfcatch type="any">
       <cfdump var="#cfcatch#">
   </cfcatch>
   </cftry> --->
               <cfinclude template="cabecalho.cfm">
                 <table width="100%" height="45%">
                  
                      <tr>
                        <td valign="top">
                          <!--- Área de conteúdo   --->

                          <!---Cria uma instância do componente Dao--->
                          <cfobject component="CFC/Dao" name="dao">

                            <table width="100%" class="exibir">
                      <cfif rsItem.recordCount neq 0>
                              <tr>
                                <td height="20%" colspan="9">
                                  <div align="center"><span class="style5">
                                      <cfoutput>#sigla#</cfoutput>
                                    </span></div>
                                </td>
                              </tr><br>
                              <tr>
                         
  
                                <td colspan="9" align="center"> <button onClick="window.close()"
                                    class="botao" style="position:relative;top:30px">Fechar</button></td>
                          
                              </tr>
                              <tr>
                                <td colspan="9">
                                  <div align="right"><a href="Fechamento/<cfoutput>#sarquivo#</cfoutput>"><img
                                        src="icones/excel.jpg" width="50" height="35" border="0 a></div>
                                </td>
                              </tr>
                              <tr><td colspan="2"></td></tr>

                              <cfif rsItem.recordCount neq 0>
                                  <tr class="titulosClaro">
                                    <td colspan="12"  class="exibir"><cfoutput>Qt. Total Itens: #rsItem.recordCount#</cfoutput></td>
                                  </tr>
                              </cfif>
                            
                              <cfoutput query="rsItem" GROUP="Und_CodDiretoria" GROUPCASESENSITIVE="No">
                                 
                                <cfquery name="rsSE" datasource="#dsn_inspecao#">
                                  Select Dir_Sigla from Diretoria WHERE Dir_Codigo = #rsItem.Und_CodDiretoria#
                                </cfquery>

                                <cfquery name="rsSEquant"  dbtype="query">
                                  Select count(Pos_Unidade) as totalSE from rsItem WHERE Und_CodDiretoria='#rsItem.Und_CodDiretoria#'
                                </cfquery>
                               
                               <cfif not isDefined("frmSE")>  
                                  <tr class="titulosClaro">
                                    <td colspan="12"  class="exibir" >
                                    <cfif #rsSEquant.totalSE# eq 1>
                                      <div align="center" style="font-size:12px;margin-top:10px;whidth:100px">SE/#rsSE.Dir_Sigla# <font style="font-size:10px;">(#rsSEquant.totalSE# item)</font></div>
                                    <cfelse>
                                      <div align="center" style="font-size:12px;margin-top:10px;whidth:100px">SE/#rsSE.Dir_Sigla# <font style="font-size:10px;">(#rsSEquant.totalSE# itens)</font></div>
                                    </cfif>
                                    </td>
                                  </tr>
                               </cfif>
                                
                                <tr class="titulosClaro">
                                <td width="5%" bgcolor="eeeeee" class="exibir">
                                  <div align="center">Status</div>
                                </td>
                                <td width="5%" bgcolor="eeeeee" class="exibir">
                                  <div align="center">Início</div>
                                </td>
                                <td width="5%" bgcolor="eeeeee" class="exibir">
                                  <div align="center">Fim</div>
                                </td>
                                <td width="5%" bgcolor="eeeeee" class="exibir">
                                  <div align="center">Envio Ponto </div>
                                </td>
                                <td width="12%" bgcolor="eeeeee" class="exibir">
                                  <div align="center">Unidade Inspecionada</div>
                                </td>
                                <td width="9%" bgcolor="eeeeee" class="exibir">
                                  <div align="center">Órgão Condutor</div>
                                </td>
                                <td width="5%" bgcolor="eeeeee" class="exibir">
                                  <div align="center">Relatório</div>
                                </td>
                                <td width="17%" bgcolor="eeeeee" class="exibir">
                                  <div align="center">Grupo</div>
                                </td>
                                <td width="20%" bgcolor="eeeeee" class="exibir">
                                  <div align="center">Item</div>
                                </td>
                                <td width="5%" bgcolor="eeeeee" class="exibir">
                                  <div align="center">Quant. de Dias</div>
                                </td>
                              </tr>

                              
                              <cfoutput>
                                
                                <!---  <cfif rsItem.Pos_Area is '#areaSubordinados#'> --->
                                <!---Invoca o metodo  DescricaoPosArea para retornar a descricao do órgão condutor--->
                                <cfinvoke component="#dao#" method="DescricaoPosArea" returnVariable="DescricaoPosArea"
                                  CodigoDaUnidade='#rsItem.pos_area#'>

                                  <tr bgcolor="f7f7f7">

                                    <td width="5%" bgcolor="#STO_Cor#">
                                      <div align="center"><a target ="_blank"
                                          href="itens_consulta_gestores_pendentes1.cfm?Unid=#rsItem.Pos_Unidade#&Ninsp=#rsItem.Pos_Inspecao#&Ngrup=#rsItem.Pos_NumGrupo#&DGrup=#rsItem.Grp_Descricao#&Nitem=#rsItem.Pos_NumItem#&Desc=#rsItem.Itn_Descricao#&Situacao=#rsItem.Pos_Situacao_Resp#&areaSubordinados=#rsItem.Pos_Area#&diasdecor=#data#"
                                          class="exibir" onMouseMove="Hint('#STO_Sigla#',2)"
                                          onMouseOut="Hint('#STO_Sigla#',1)"><strong>#trim(STO_Descricao)#</strong></a>
                                      </div>
                                    </td>
                                    <td width="5%">
                                      <div align="center">#DateFormat(rsItem.INP_DtInicInspecao,'DD/MM/YYYY')#</div>
                                    </td>
                                    <td width="5%">
                                      <div align="center">#DateFormat(rsItem.INP_DtFimInspecao,'DD/MM/YYYY')#</div>
                                    </td>
                                    <td width="5%">
                                      <div align="center">#DateFormat(rsItem.INP_DtEncerramento,'DD/MM/YYYY')#</div>
                                    </td>
                                    <td width="12%">
                                      <div align="center">#rsItem.Und_Descricao#</div>
                                    </td>
                                    <td width="12%">
                                      <div align="center">#DescricaoPosArea#</div>
                                    </td>
                                    <td width="5%">
                                      <div align="center">#rsItem.Pos_Inspecao#</div>
                                    </td>
                                    <td width="17%">
                                      <div align="center"><strong>#rsItem.Pos_NumGrupo#</strong> -
                                        #rsItem.Grp_Descricao#</div>
                                    </td>
                                    <td width="20%">
                                      <div align="justify"><strong>#rsItem.Pos_NumItem#</strong> -
                                        &nbsp;#rsItem.Itn_Descricao#</div>
                                    </td>
                                    <td width="5%">
                                      <div align="center"><strong>#rsItem.Quant#</strong></div>
                                    </td>
                                  </tr>
                                  <!---  </cfif> --->
                              </cfoutput>
                            </cfoutput>

                          <cfelse>
                            <tr>
                              <td colspan="9" align="center"><div style="color:red;font-size:15px; margin-top:50px">Caro usuário, não foram localizados itens para os parâmetros informados.</div></td>
                            </tr>

                          </cfif>
                              <tr>
                                <td colspan="9" align="center">&nbsp;</td>
                              </tr>

                              <tr>
                                <td colspan="9" align="center"> <button onClick="window.close()"
                                    class="botao">Fechar</button></td>
                              </tr>
                              
                            </table>

                            <!--- Fim Área de conteúdo --->
                        </td>
                      </tr>
                   

                    </table>






                    <cfinclude template="rodape.cfm">





      </body>

      </html>

      <cfelse>
        <cfinclude template="permissao_negada.htm">
          <cfabort>
    </cfif>
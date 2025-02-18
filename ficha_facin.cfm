<cfprocessingdirective pageEncoding ="utf-8">  
<!---
<cfoutput>
<cfdump var="#form#">
</cfoutput>
--->
<cfset grp = ''>
<cfset itm = ''>
<cfloop list="#form.grpitem#" index="vlr">
    <cfif grp eq ''>
        <cfset grp = vlr>
    <cfelse>
        <cfset itm = vlr>
    </cfif>
</cfloop>  

<cfoutput>
    <cfquery name="qAcesso" datasource="#dsn_inspecao#">
        select Usu_Matricula,Usu_GrupoAcesso 
        from usuarios 
        where Usu_login = '#cgi.REMOTE_USER#'
    </cfquery>
    <cfset grpacesso = ucase(Trim(qAcesso.Usu_GrupoAcesso))>
     
    <cfquery datasource="#dsn_inspecao#" name="rsFicha">
        SELECT Diretoria.Dir_Sigla as siglainsp, INP_NumInspecao, INP_Unidade, INP_DtInicInspecao, INP_DtFimInspecao, INP_DTConcluirAvaliacao, INP_DTConcluirRevisao, 
        INP_Coordenador, Fun_Nome, Fun_Matric, IPT_MatricInspetor, 
        Usuarios.Usu_LotacaoNome, Usuarios_1.Usu_Apelido as nomerevisor, Usuarios_1.Usu_LotacaoNome as lotacaorevisor, 
        Usuarios_1.Usu_Matricula as matrrevisor, Und_Descricao, Diretoria_1.Dir_Sigla, Diretoria_2.Dir_Sigla as siglaunid
        FROM (((((((Inspecao INNER JOIN 
        Inspetor_Inspecao ON (INP_NumInspecao = IPT_NumInspecao) AND (INP_Unidade = IPT_CodUnidade)) 
        INNER JOIN Unidades ON INP_Unidade = Und_Codigo) 
        INNER JOIN Funcionarios ON IPT_MatricInspetor = Fun_Matric) 
        INNER JOIN Usuarios ON Fun_Matric = Usuarios.Usu_Matricula) 
        INNER JOIN Usuarios AS Usuarios_1 ON INP_UserName = Usuarios_1.Usu_Login) 
        INNER JOIN Diretoria AS Diretoria_1 ON Usuarios_1.Usu_DR = Diretoria_1.Dir_Codigo) 
        INNER JOIN Diretoria ON Fun_DR = Diretoria.Dir_Codigo) 
        INNER JOIN Diretoria AS Diretoria_2 ON Und_CodDiretoria = Diretoria_2.Dir_Codigo
        WHERE INP_NumInspecao = convert(varchar,'#form.numinsp#') 
    </cfquery>

 <cfif form.acao eq 'inc'>
    <cfif grpacesso neq 'INSPETORES'>
        <cfquery datasource="#dsn_inspecao#" name="rsItem">
            SELECT RIP_Resposta, Itn_NumGrupo, Itn_NumItem, Itn_Descricao, Grp_Descricao, RIP_MatricAvaliador, Fun_Nome, Fun_Email, FACA_Matricula, FACA_Meta1_AT_OrtoGram, FACA_Meta1_AT_CCCP, FACA_Meta1_AE_Tecn, FACA_Meta1_AE_Prob, FACA_Meta1_AE_Valor, FACA_Meta1_AE_Cosq, FACA_Meta1_AE_Norma, FACA_Meta1_AE_Docu, 
            FACA_Meta1_AE_Class, FACA_Meta1_AE_Orient, FACA_Meta1_Pontos, FACA_Meta2_AR_Falta, FACA_Meta2_AR_Troca, FACA_Meta2_AR_Nomen, FACA_Meta2_AR_Ordem, FACA_Meta2_AR_Prazo, FACA_Meta2_Pontos,FACA_Avaliacao,FACA_Consideracao
            FROM Unidades 
            INNER JOIN ((Inspecao 
            INNER JOIN Resultado_Inspecao ON (INP_Unidade = RIP_Unidade) AND (INP_NumInspecao = RIP_NumInspecao)) 
            INNER JOIN Itens_Verificacao ON (INP_Modalidade = Itn_Modalidade) AND (RIP_NumItem = Itn_NumItem) AND (RIP_NumGrupo = Itn_NumGrupo)) ON (Und_TipoUnidade = Itn_TipoUnidade) AND (Und_Codigo = RIP_Unidade)
            INNER JOIN Grupos_Verificacao ON (Itn_NumGrupo = Grp_Codigo) AND (Itn_Ano = Grp_Ano)
            INNER JOIN Funcionarios ON RIP_MatricAvaliador = Fun_Matric
            left JOIN UN_Ficha_Facin_Avaliador ON (RIP_NumInspecao = FACA_Avaliacao) AND (RIP_Unidade = FACA_Unidade) AND (RIP_MatricAvaliador = FACA_Avaliador) AND (Itn_NumGrupo = FACA_Grupo) AND (Itn_NumItem = FACA_Item)
            WHERE convert(char, RIP_Ano) = Itn_Ano AND INP_NumInspecao = convert(varchar,'#form.numinsp#') 
            AND RIP_Resposta <> 'A' and Itn_NumGrupo=#grp#  and Itn_NumItem = #itm#
        </cfquery>
    <cfelse>   
        <cfquery datasource="#dsn_inspecao#" name="rsItem">
            SELECT RIP_Resposta, Itn_NumGrupo, Itn_NumItem, Itn_Descricao, Grp_Descricao, RIP_MatricAvaliador, Fun_Nome, Fun_Email, FACA_Matricula, FACA_Meta1_AT_OrtoGram, FACA_Meta1_AT_CCCP, FACA_Meta1_AE_Tecn, FACA_Meta1_AE_Prob, FACA_Meta1_AE_Valor, FACA_Meta1_AE_Cosq, FACA_Meta1_AE_Norma, FACA_Meta1_AE_Docu, 
            FACA_Meta1_AE_Class, FACA_Meta1_AE_Orient, FACA_Meta1_Pontos, FACA_Meta2_AR_Falta, FACA_Meta2_AR_Troca, FACA_Meta2_AR_Nomen, FACA_Meta2_AR_Ordem, FACA_Meta2_AR_Prazo, FACA_Meta2_Pontos,FACA_Avaliacao,FACA_Consideracao
            FROM Unidades 
            INNER JOIN ((Inspecao 
            INNER JOIN Resultado_Inspecao ON (INP_Unidade = RIP_Unidade) AND (INP_NumInspecao = RIP_NumInspecao)) 
            INNER JOIN Itens_Verificacao ON (INP_Modalidade = Itn_Modalidade) AND (RIP_NumItem = Itn_NumItem) AND (RIP_NumGrupo = Itn_NumGrupo)) ON (Und_TipoUnidade = Itn_TipoUnidade) AND (Und_Codigo = RIP_Unidade)
            INNER JOIN Grupos_Verificacao ON (Itn_NumGrupo = Grp_Codigo) AND (Itn_Ano = Grp_Ano)
            INNER JOIN Funcionarios ON RIP_MatricAvaliador = Fun_Matric
            INNER JOIN UN_Ficha_Facin_Avaliador ON (RIP_NumInspecao = FACA_Avaliacao) AND (RIP_Unidade = FACA_Unidade) AND (RIP_MatricAvaliador = FACA_Avaliador) AND (Itn_NumGrupo = FACA_Grupo) AND (Itn_NumItem = FACA_Item)
            WHERE convert(char, RIP_Ano) = Itn_Ano AND INP_NumInspecao = convert(varchar,'#form.numinsp#') 
            AND RIP_Resposta <> 'A' and Itn_NumGrupo=#grp#  and Itn_NumItem = #itm# and RIP_MatricAvaliador = '#qAcesso.Usu_Matricula#'
        </cfquery>      
    </cfif>
<cfelse>
    <cfquery datasource="#dsn_inspecao#" name="rsItem">
        SELECT RIP_Resposta, Itn_NumGrupo, Itn_NumItem, Itn_Descricao, Grp_Descricao, RIP_MatricAvaliador, Fun_Nome, Fun_Email, FACA_Matricula, FACA_Meta1_AT_OrtoGram, FACA_Meta1_AT_CCCP, FACA_Meta1_AE_Tecn, FACA_Meta1_AE_Prob, FACA_Meta1_AE_Valor, FACA_Meta1_AE_Cosq, FACA_Meta1_AE_Norma, FACA_Meta1_AE_Docu, 
		FACA_Meta1_AE_Class, FACA_Meta1_AE_Orient, FACA_Meta1_Pontos, FACA_Meta2_AR_Falta, FACA_Meta2_AR_Troca, FACA_Meta2_AR_Nomen, FACA_Meta2_AR_Ordem, FACA_Meta2_AR_Prazo, FACA_Meta2_Pontos,FACA_Avaliacao,FACA_Consideracao
        FROM Unidades 
        INNER JOIN ((Inspecao 
        INNER JOIN Resultado_Inspecao ON (INP_Unidade = RIP_Unidade) AND (INP_NumInspecao = RIP_NumInspecao)) 
        INNER JOIN Itens_Verificacao ON (INP_Modalidade = Itn_Modalidade) AND (RIP_NumItem = Itn_NumItem) AND (RIP_NumGrupo = Itn_NumGrupo)) ON (Und_TipoUnidade = Itn_TipoUnidade) AND (Und_Codigo = RIP_Unidade)
        INNER JOIN Grupos_Verificacao ON (Itn_NumGrupo = Grp_Codigo) AND (Itn_Ano = Grp_Ano)
        INNER JOIN Funcionarios ON RIP_MatricAvaliador = Fun_Matric
        INNER JOIN UN_Ficha_Facin_Avaliador ON (RIP_NumInspecao = FACA_Avaliacao) AND (RIP_Unidade = FACA_Unidade) AND (RIP_MatricAvaliador = FACA_Avaliador) AND (Itn_NumGrupo = FACA_Grupo) AND (Itn_NumItem = FACA_Item)
        WHERE convert(char, RIP_Ano) = Itn_Ano AND INP_NumInspecao = convert(varchar,'#form.numinsp#') 
        AND RIP_Resposta <> 'A' and Itn_NumGrupo=#grp#  and Itn_NumItem = #itm# and FACA_Matricula = '#qAcesso.Usu_Matricula#'
    </cfquery>    
</cfif>    
   <cfquery datasource="#dsn_inspecao#" name="rsRIP">
        SELECT RIP_NumInspecao, Count(RIP_NumInspecao) AS TotalRIP
        FROM Resultado_Inspecao
        GROUP BY RIP_NumInspecao
        HAVING RIP_NumInspecao=convert(varchar,'#form.numinsp#')
    </cfquery>
    
    <cfquery datasource="#dsn_inspecao#" name="rsAvalia">
        SELECT RIP_MatricAvaliador, Fun_Nome, Count(RIP_MatricAvaliador) AS totaval
        FROM Resultado_Inspecao 
        INNER JOIN Funcionarios ON RIP_MatricAvaliador = Fun_Matric
        GROUP BY RIP_NumInspecao, RIP_MatricAvaliador, Fun_Nome
        HAVING RIP_NumInspecao = convert(varchar,'#form.numinsp#') 
        <cfif grpacesso eq 'INSPETORES'>
            AND RIP_MatricAvaliador = '#qAcesso.Usu_Matricula#'
        </cfif>
    </cfquery>

    <cfquery datasource="#dsn_inspecao#" name="rsDevol">
        SELECT RIP_NumInspecao, Count(RIP_NumInspecao) AS totdevol
        FROM Resultado_Inspecao
        WHERE RIP_Recomendacao_Inspetor Is Not Null
        GROUP BY RIP_NumInspecao
        HAVING RIP_NumInspecao = convert(varchar,'#form.numinsp#')
    </cfquery>

    <cfquery datasource="#dsn_inspecao#" name="rsExisteFacin">
        SELECT FAC_Qtd_Geral, FAC_Qtd_NC, FAC_Qtd_Devolvido, 
        FAC_Pontos_Revisao_Meta1, FAC_Perc_Revisao_Meta1, FAC_Meta1_Peso_Item, FAC_Pontos_Revisao_Meta2, FAC_Perc_Revisao_Meta2, FAC_Meta2_Peso_Item, FAC_Data_Plan_Meta3, 
        FAC_DifDia_Meta3, FAC_Perc_Meta3, FAC_DtAlter,FAC_DtConcluirFacin
        FROM UN_Ficha_Facin
        WHERE FAC_Avaliacao = convert(varchar,'#form.numinsp#') and FAC_Matricula = '#qAcesso.Usu_Matricula#'
    </cfquery>

    <cfif rsExisteFacin.recordcount lte 0>
        <cfset form.ptogeral = #rsRIP.TotalRIP#>
        <cfset form.meta1 = 100>
        <cfset form.meta2 = 100>
        <cfset form.ptorevismeta1 = #rsRIP.TotalRIP#>
        <cfset form.ptorevismeta2 = #rsRIP.TotalRIP#>
    <cfelse>
        <cfset form.ptogeral = #rsExisteFacin.FAC_Qtd_Geral#>
        <cfset form.ptodev = #rsExisteFacin.FAC_Qtd_Devolvido#>
        <cfset form.meta1 = #rsExisteFacin.FAC_Perc_Revisao_Meta1#>
        <cfset form.meta2 = #rsExisteFacin.FAC_Perc_Revisao_Meta2#>
        <cfset form.ptorevismeta1 = #rsExisteFacin.FAC_Pontos_Revisao_Meta1#>
        <cfset form.ptorevismeta2 = #rsExisteFacin.FAC_Pontos_Revisao_Meta2#>
    </cfif>
    <cfset ptogrpitm = numberFormat((100/form.ptogeral),'___.0')>

<!DOCTYPE html>
<html lang="pt-BR">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FICHA AVALIAÇÃO</title>
    <link rel="stylesheet" href="public/bootstrap/bootstrap.min.css">
     <link rel="stylesheet" href="public/app.css">  

    <script>

        //===========  
        const second = 1000;
        const minute = second * 60;
        const hour = minute * 60;
        const day = hour * 24;

        function meta3(a,b){
            //alert(a + '' + b)
          //  alert(document.formx.concaval.value);
          if (a.length == 10){
            let date_realizado = new Date(a);
            let date_planejado = new Date(b);
            var percent=100;
            //alert(date_ini + '   ' + date_end);
            let diff = date_planejado.getTime() - date_realizado.getTime();
            diff = Math.floor(diff / day);
            //alert(diff);
           if(diff < 0){
                //diff = 0;
                //document.formx.meta3_dtplanej.value = a;
            }
            
            if(diff < 0){
               // alert('linha 168')
               if(diff == -1) {percent = 60}  
               if(diff == -2) {percent = 40}
               if(diff <= -3) {percent = 0;}
            }else{
                if(diff > 0) {percent = 110;}
            }
//alert(percent)
            document.getElementById('meta3_dif').innerText = diff;
            document.getElementById('meta3_percent').innerText = percent + '%';
            document.formx.facdataplanmeta3.value = b;
            document.formx.facdifdiameta3.value = diff;
            document.formx.facpercmeta3.value = percent;
            }
        
        }        
        //===========
        function numericos(){
            var tecla = window.event.keyCode;
            if ((tecla != 46) && ((tecla < 48) || (tecla > 57))){
                event.returnValue = false; 
            }
        }
        //================ 
        function Mascara_Data(data){
	        switch (data.value.length)
	        {
                case 2:
                if (data.value < 1 || data.value > 31) {
                    //alert('Valor para o dia inválido!');
                    data.value = '';
                    event.returnValue = false;
                    break;
                    } else {
                    data.value += "/";
                        break;
                    }
                case 5:
                if (data.value.substring(3,5) < 1 || data.value.substring(3,5) > 12) {
               // alert('Valor para o Mês inválido!');
                data.value = '';
                event.returnValue = false;
                break;
                } else {
                data.value += "/";
                    break;
                }
	        }
        }	
  
</script>

</head>

<!--- <body onload="meta2(true,1,1,85051071);colecao_meta2(85051071)"> --->
<body onload="">
<!--- <form name="facin" method="POST" action=""> --->
<form name="formx" method="POST" action="cfc/fichafacin.cfc?method=salvarPosic" target="_self">
<div class="container">
	<div class="row align-items-center">
        <span class="border border-primary">
            <p class="text-center"><strong>(FACIN) - FICHA DE AVALIAÇÃO DE CONTROLE INTERNO ANO 2024 - SGCIN/PE</strong></p>
        </span>  
                
        <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>01-Identificação</strong></label>
        <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>Inspetores</strong></label>
    

        <div class="col-sm-5">
            <cfloop query="rsFicha">
                <p class="text-start">
                <cfif trim(rsFicha.INP_Coordenador) eq trim(rsFicha.IPT_MatricInspetor)>
                    <label for="" class="">&nbsp;#rsFicha.Fun_Nome# <strong>(coordenador(a))</strong></label>
                <cfelse>  
                    <label for="" class="">&nbsp;#rsFicha.Fun_Nome#</label>              
                </cfif>
                </p>            
            </cfloop>    
        </div>
        <div class="col-sm-2">
            <cfloop query="rsFicha">
                <p>&nbsp;#rsFicha.IPT_MatricInspetor#</p>
            </cfloop>  
        </div>
        <div class="col-sm-5">
            <cfloop query="rsFicha">
            <p>
                #rsFicha.Usu_LotacaoNome#(SE-#rsFicha.siglainsp#)    
            </p>           
            </cfloop>  
        </div>


    <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>Revisor(a)</strong></label>

        <div class="col-sm-5">
            #rsFicha.nomerevisor#        
        </div>
        <div class="col-sm-1">
            #rsFicha.matrrevisor#                 
        </div>
        <div class="col-sm-6">
                #rsFicha.lotacaorevisor#(SE-#rsFicha.Dir_Sigla#)              
        </div>

    <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>02.Processo Avaliado</strong></label>

        <div class="col-sm-6">
            Unidade: #rsFicha.Und_Descricao#(SE/#rsFicha.siglaunid#)
        </div>
        <div class="col-sm-6">
            Nº Avaliação: #rsFicha.INP_NumInspecao#                
        </div>

    <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>03.Período das fases da Avaliação de Controle Interno</strong></label>
    <label for="" class="col-sm-3 col-form-label">&nbsp;Execução em campo</label>
    <label for="" class="col-sm-3 col-form-label">&nbsp;Conclusão Avaliação</label>
    <label for="" class="col-sm-3 col-form-label">&nbsp;Conclusão Revisão</label>
    <label for="" class="col-sm-3 col-form-label">&nbsp;Conclusão SEI</label>
    <label for="" class="col-sm-3 col-form-label">&nbsp;Início: #dateformat(rsFicha.INP_DtInicInspecao,"DD/MM/YYYY")# Fim: #dateformat(rsFicha.INP_DtFimInspecao,"DD/MM/YYYY")#</label>
    <label id="concluiraval" for="" class="col-sm-3 col-form-label">#dateformat(rsFicha.INP_DTConcluirAvaliacao,"DD/MM/YYYY")#</label>
    <cfset datarevis = dateformat(rsFicha.INP_DTConcluirRevisao,"DD/MM/YYYY")>
    <cfif rsFicha.INP_DTConcluirRevisao eq ''>
        <cfset datarevis = dateformat(now(),"DD/MM/YYYY")>
    </cfif>
    <input type="hidden" name="concaval" value="#dateformat(rsFicha.INP_DTConcluirAvaliacao,"YYYY-MM-DD")#">
    <label for="" class="col-sm-3 col-form-label">&nbsp;#datarevis#</label>
    <label for="" class="col-sm-3 col-form-label">&nbsp;#dateformat(rsFicha.INP_DTConcluirAvaliacao,"DD/MM/YYYY")#</label>
    <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>04.Avaliação</strong></label>
    <label for="" class="col-sm-4 col-form-label">&nbsp;Qtd. Geral de Pontos &nbsp;<div id="ptogeral" class="badge bg-primary text-wrap" style="width: 4rem;">#form.ptogeral#</div></label>
    <!--- <cfif rsExisteFacin.recordcount lte 0> --->
        <cfset form.ptodev = 0>
        <cfset auxpercptodev = 0>
        <cfif rsDevol.totdevol gt 0>
            <cfset form.ptodev = rsDevol.totdevol>
            <cfset auxpercptodev = (form.ptodev / form.ptogeral) * 100>
            <cfset auxpercptodev = numberFormat(auxpercptodev,'___.00')>
        </cfif>
    <!--- </cfif>     --->
    <label for="" class="col-sm-4 col-form-label">&nbsp;Qtd. Pontos Devolvidos &nbsp;<div id="ptodev" class="badge bg-primary text-wrap" style="width: 3rem;">#form.ptodev#</div></label>
    <label for="" class="col-sm-4 col-form-label">&nbsp;Percentual de Devolução&nbsp;<div id="perdev" class="badge bg-primary text-wrap" style="width: 5rem;"><cfoutput>#auxpercptodev#</cfoutput>%</div></label>

  
    <label for="" class="col-sm-6 col-form-label">&nbsp;Pontos Obtidos na Revisão Geral (Meta1) <div id="meta1" class="badge bg-primary text-wrap" style="width: 5rem;">#form.meta1#%</div></label>
    <label for="" class="col-sm-6 col-form-label">&nbsp;Pontos Obtidos na Revisão Geral (Meta2) <div id="meta2" class="badge bg-primary text-wrap" style="width: 5rem;">#form.meta2#%</div></label>
    <label for="" class="col-sm-6 col-form-label"><div id="ptorevismeta1" class="badge bg-primary text-wrap" style="width: 5rem;"><cfoutput>#form.ptorevismeta1#</cfoutput></div></label>
    <label for="" class="col-sm-6 col-form-label"><div id="ptorevismeta2" class="badge bg-primary text-wrap" style="width: 5rem;"><cfoutput>#form.ptorevismeta2#</cfoutput></div></label>
    <p class="text-center"><strong>METAS</strong></p>
</cfoutput>

<div class="accordion" id="acordiongrupoitem">
  <cfset ordem = 0>
  <cfloop query="rsItem">
    <cfset ordem = ordem + 1>
    <cfset linha = 'A_' & rsItem.Itn_NumGrupo & '_' & rsItem.Itn_NumItem>
    <cfset grpitm = rsItem.Itn_NumGrupo & '_' & rsItem.Itn_NumItem>
    
  <div class="accordion-item">
    <h2 class="accordion-header" id="headingOne">
      <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#<cfoutput>#linha#</cfoutput>" aria-expanded="true" aria-controls="<cfoutput>#linha#</cfoutput>">
        <cfoutput>
            #grpitm# - #rsItem.Grp_Descricao# &nbsp;&nbsp;Avaliador(a) : #rsItem.RIP_MatricAvaliador# - #rsItem.Fun_Nome# - #rsItem.Fun_Email# 
        </cfoutput>
      </button>
    </h2>
    <div id="<cfoutput>#linha#</cfoutput>" class="accordion-collapse collapse" aria-labelledby="headingOne" data-bs-parent="#acordiongrupoitem">
      <div class="accordion-body">
        <cfoutput>#rsItem.Itn_Descricao#</cfoutput>
      </div>

      <table class="table">
        <tbody>
            <!--- Aspectos Textuais --->
            <tr>
                <td align="center">
                    <strong>Meta 1: Redigir Apontamentos no SNCI</strong>
                </td>
            </tr>
            <cfset form.meta1_pto = #ptogrpitm#>
            <cfif rsItem.FACA_Avaliacao neq ''><cfset form.meta1_pto = #rsItem.FACA_Meta1_Pontos#></cfif>            
            <tr>
                <tr>
                    <td>Pontuação Obtida por Avaliador/Grupo_Item</td>
                    <td>
                        <div class="badge bg-primary text-wrap" style="width: 5rem;">
                            <input class="form-control" type="text" id="meta1_pto_obtida" name="meta1_pto_obtida" value="<cfoutput>#form.meta1_pto#</cfoutput>" readonly>
                        </div>
                    </td>
                </tr>
            </tr>
            <tr>
                <td align="center">
                    <strong>Aspectos Textuais</strong>
                </td>
            </tr>
            <cfset auxchck = ''>
            <cfset auxvlr = 0>
            <cfif rsItem.FACA_Meta1_AT_OrtoGram eq 1 and rsItem.FACA_Matricula eq qAcesso.Usu_Matricula><cfset auxchck = 'checked'><cfset auxvlr = 1></cfif>   
            <tr>
                <td>Ortografia e Gramática</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input meta1" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta1_atorgr" value="<cfoutput>#auxvlr#</cfoutput>">
                    </div>
                </td>
            </tr>
            <cfset auxchck = ''>
            <cfset auxvlr = 0>
            <cfif rsItem.FACA_Meta1_AT_CCCP eq 1 and rsItem.FACA_Matricula eq qAcesso.Usu_Matricula><cfset auxchck = 'checked'><cfset auxvlr = 1></cfif>              
            <tr>
                <td>Clareza/Concisão e/ou Coerência/Precisão</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input meta1" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta1_atcccp" value="<cfoutput>#auxvlr#</cfoutput>">
                    </div>
                </td>
            </tr>
            <!--- Redigir apontamentos no SNCI --->

            <tr>
                <td align="Center"><strong>Aspectos Estruturais</strong></td>
            </tr>
            <cfset auxchck = ''>
            <cfset auxvlr = 0>
            <cfif rsItem.FACA_Meta1_AE_Tecn eq 1 and rsItem.FACA_Matricula eq qAcesso.Usu_Matricula><cfset auxchck = 'checked'><cfset auxvlr = 1></cfif>               
            <tr>
                <td>Técnica</td>
                <td>
                    <div class="form-check form-switch">
                         <input class="form-check-input meta1" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta1_aetecn" value="<cfoutput>#auxvlr#</cfoutput>"> 
                    </div>
                </td>
            </tr>
            <cfset auxchck = ''>
            <cfset auxvlr = 0>
            <cfif rsItem.FACA_Meta1_AE_Prob eq 1 and rsItem.FACA_Matricula eq qAcesso.Usu_Matricula><cfset auxchck = 'checked'><cfset auxvlr = 1></cfif>              
            <tr>
                <td>Problema</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input meta1" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta1_aeprob" value="<cfoutput>#auxvlr#</cfoutput>">
                    </div>
                </td>
            </tr>
            <cfset auxchck = ''>
            <cfset auxvlr = 0>
            <cfif rsItem.FACA_Meta1_AE_Valor eq 1 and rsItem.FACA_Matricula eq qAcesso.Usu_Matricula><cfset auxchck = 'checked'><cfset auxvlr = 1></cfif>                 
            <tr>
                <td>Valor</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input meta1" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta1_aevalo" value="<cfoutput>#auxvlr#</cfoutput>">
                    </div>
                </td>
            </tr>
            <cfset auxchck = ''>
            <cfset auxvlr = 0>
            <cfif rsItem.FACA_Meta1_AE_Cosq eq 1 and rsItem.FACA_Matricula eq qAcesso.Usu_Matricula><cfset auxchck = 'checked'><cfset auxvlr = 1></cfif>              
            <tr>
                <td>Consequências</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input meta1" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta1_aecsqc" value="<cfoutput>#auxvlr#</cfoutput>">
                    </div>
                </td>
            </tr>
            <cfset auxchck = ''>
            <cfset auxvlr = 0>
            <cfif rsItem.FACA_Meta1_AE_Norma eq 1 and rsItem.FACA_Matricula eq qAcesso.Usu_Matricula><cfset auxchck = 'checked'><cfset auxvlr = 1></cfif>              
            <tr>
                <td>Normativo</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input meta1" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta1_aenorm" value="<cfoutput>#auxvlr#</cfoutput>">
                    </div>
                </td>
            </tr>
            <cfset auxchck = ''>
            <cfset auxvlr = 0>
            <cfif rsItem.FACA_Meta1_AE_Docu eq 1 and rsItem.FACA_Matricula eq qAcesso.Usu_Matricula><cfset auxchck = 'checked'><cfset auxvlr = 1></cfif>                
            <tr>
                <td>Documentos</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input meta1" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta1_aedocm" value="<cfoutput>#auxvlr#</cfoutput>">
                    </div>
                </td>
            </tr>
            <cfset auxchck = ''>
            <cfset auxvlr = 0>
            <cfif rsItem.FACA_Meta1_AE_Class eq 1 and rsItem.FACA_Matricula eq qAcesso.Usu_Matricula><cfset auxchck = 'checked'><cfset auxvlr = 1></cfif>                
            <tr>
                <td>Classificação</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input meta1" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta1_aeclas" value="<cfoutput>#auxvlr#</cfoutput>">
                    </div>
                </td>
            </tr>
            <cfset auxchck = ''>
            <cfset auxvlr = 0>
            <cfif rsItem.FACA_Meta1_AE_Orient eq 1 and rsItem.FACA_Matricula eq qAcesso.Usu_Matricula><cfset auxchck = 'checked'><cfset auxvlr = 1></cfif>               
            <tr>
                <td>Orientação</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input meta1" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta1_orient" value="<cfoutput>#auxvlr#</cfoutput>">
                    </div>
                </td>
            </tr>
            <!--- FIM Redigir apontamentos no SNCI ---> 
            <!--- Meta 2: Organizar documentos no SEI --->
            <tr>
                <td align="center">
                    <strong>Meta 2: Organizar Documentos no SEI</strong>
                </td>
            </tr>
            <cfset form.meta2_pto = #ptogrpitm#>
            <cfif rsItem.FACA_Avaliacao neq ''><cfset form.meta2_pto = #rsItem.FACA_Meta2_Pontos#></cfif>                
            <tr>
                <td>Pontuação Obtida por Avaliador/Grupo_Item </td>
                <td>
                    <div class="badge bg-primary text-wrap" style="width: 5rem;">
                        <input class="form-control" type="text" id="meta2_pto_obtida" name="meta2_pto_obtida" value="<cfoutput>#form.meta2_pto#</cfoutput>" readonly>
                    </div>
                </td>
            </tr> 
            <tr>
                <td align="center">
                    <strong>Arquivo</strong>
                </td>
            </tr>
            <cfset auxchck = ''>
            <cfset auxvlr = 0>
            <cfif rsItem.FACA_Meta2_AR_Falta eq 1 and rsItem.FACA_Matricula eq qAcesso.Usu_Matricula><cfset auxchck = 'checked'><cfset auxvlr = 1></cfif>  
            <tr>
                <td>Falta</td>
                <td>
                    <div class="form-check form-switch">                                                                                                                                                                             
                        <input class="form-check-input meta2" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta2_arfalt" value="<cfoutput>#auxvlr#</cfoutput>">
                    </div>
                </td>
            </tr>
            <cfset auxchck = ''>
            <cfset auxvlr = 0>
            <cfif rsItem.FACA_Meta2_AR_Troca eq 1 and rsItem.FACA_Matricula eq qAcesso.Usu_Matricula><cfset auxchck = 'checked'><cfset auxvlr = 1></cfif>             
            <tr>
                <td>Troca</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input meta2" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta2_artroc" value="<cfoutput>#auxvlr#</cfoutput>">
                    </div>
                </td>
            </tr>
            <cfset auxchck = ''>
            <cfset auxvlr = 0>
            <cfif rsItem.FACA_Meta2_AR_Nomen eq 1 and rsItem.FACA_Matricula eq qAcesso.Usu_Matricula><cfset auxchck = 'checked'><cfset auxvlr = 1></cfif>               
            <tr>
                <td>Nomenclatura</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input meta2" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta2_arnomc" value="<cfoutput>#auxvlr#</cfoutput>">
                    </div>
                </td>
            </tr>
            <cfset auxchck = ''>
            <cfset auxvlr = 0>
            <cfif rsItem.FACA_Meta2_AR_Ordem eq 1 and rsItem.FACA_Matricula eq qAcesso.Usu_Matricula><cfset auxchck = 'checked'><cfset auxvlr = 1></cfif>                
            <tr>
                <td>Ordem</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input meta2" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta2_arorde" value="<cfoutput>#auxvlr#</cfoutput>">
                    </div>
                </td>
            </tr>
            <cfset auxchck = ''>
            <cfset auxvlr = 0>
            <cfif rsItem.FACA_Meta2_AR_Prazo eq 1 and rsItem.FACA_Matricula eq qAcesso.Usu_Matricula><cfset auxchck = 'checked'><cfset auxvlr = 1></cfif>                  
            <tr>
                <td>Prazo</td>
                <td>
                    <div class="form-check form-switch">
                        <input class="form-check-input meta2" <cfoutput>#auxchck#</cfoutput> type="checkbox" role="switch" id="meta2_arpraz" value="<cfoutput>#auxvlr#</cfoutput>">
                    </div>
                </td>
            </tr>     
            <!--- FIM Meta 2: Organizar documentos no SEI --->
        </tbody>
      </table>
      <div class="row align-items-center">
        <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>Considerações do Item</strong></label>
        <textarea cols="94" rows="5" wrap="VIRTUAL" name="considerar" id="considerar" class="form-control" placeholder="Considerações para Grupo/Item" onblur="consideracao('<cfoutput>#grpitm#</cfoutput>',this.value)"><cfoutput>#trim(rsItem.FACA_Consideracao)#</cfoutput></textarea>	        
    </div>  
      <cfset inspetorhd =''>
      <cfif grpacesso eq 'INSPETORES'>
        <cfset inspetorhd ='readonly'>       
      </cfif>
      <cfset form.considerar = ''>
      <cfif rsItem.FACA_Avaliacao neq ''>
        <cfset form.considerar = trim(rsItem.FACA_Consideracao)>
      </cfif>      
    </div>
</cfloop> 
</div>

</div>
</div> 

<cfoutput>
  <!---  
    <div class="row align-items-center">
        <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>05-Considerações Gerais</strong></label>
        <textarea cols="94" rows="5" wrap="VIRTUAL" name="considerar" id="considerar" class="form-control" placeholder="Considerações para Avaliação" onblur="consideracao('<cfoutput>#grpitm#</cfoutput>',this.value)"><cfoutput>#trim(rsItem.FACA_Consideracao)#</cfoutput></textarea>	        
    </div>    
--->    
    <div class="row align-items-center">
    <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>05-Individualização do resultado das metas por inspetor (a ser preenchido pela equipe de inspetores):</strong></label>
    <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>Meta 1</strong> - INSP - Redigir 100% dos apontamentos relativos às Não Conformidades (NC) identificadas, conforme critérios definidos pela SGCIN/PE. (Redigir apontamentos)</label>
    <cfloop query="rsAvalia">
        <cfset matraval = rsAvalia.RIP_MatricAvaliador>
        <cfquery datasource="#dsn_inspecao#" name="rsFacinInd">
            SELECT FFI_Meta1_Qtd_Item, FFI_Meta1_Pontuacao_Inicial, FFI_Meta1_Pontuacao_Obtida, FFI_Meta1_Resultado,FFI_Consideracao_Inspetor
            FROM UN_Ficha_Facin_Individual
            WHERE FFI_Avaliacao=convert(varchar,'#form.numinsp#') AND FFI_Avaliador='#rsAvalia.RIP_MatricAvaliador#' and  FFI_Matricula = '#qAcesso.Usu_Matricula#'
        </cfquery>
        <cfset form.meta1_qggitens = #rsAvalia.totaval#>
        <cfset form.meta1_qgptop = (rsAvalia.totaval * ptogrpitm)>
        <cfset form.meta1_qgpto = (rsAvalia.totaval * ptogrpitm)>
        <cfset percent = ((rsAvalia.totaval * ptogrpitm) / (rsAvalia.totaval * ptogrpitm)) * 100>
        <cfset form.meta1_percqggitens = numberFormat(percent,'___.00')>
        
        <cfif rsFacinInd.recordcount gt 0>
            <cfset form.meta1_qggitens = #rsFacinInd.FFI_Meta1_Qtd_Item#>
            <cfset form.meta1_qgptop = #rsFacinInd.FFI_Meta1_Pontuacao_Inicial#>
            <cfset form.meta1_qgpto = #rsFacinInd.FFI_Meta1_Pontuacao_Obtida#>
            <cfset form.meta1_percqggitens = #rsFacinInd.FFI_Meta1_Resultado#>
        </cfif>
        
        <div class="col-sm-4">
            <label for="" class="">&nbsp;#rsAvalia.Fun_Nome#</label>  
        </div>
        <div class="col-sm-8">
            <label>&nbsp;Qtd. Item Avaliado: &nbsp;<div id="meta1_qggitens_#matraval#" class="badge bg-primary text-wrap" style="width: 4rem;">#form.meta1_qggitens#</div></label>
            <label>&nbsp;Pontuação Inicial:&nbsp;<div id="meta1_qgptop_#matraval#" class="badge bg-primary text-wrap" style="width: 4rem;">#form.meta1_qgptop#</div></label>
            <label>&nbsp;Pontuação Obtida:&nbsp;<div id="meta1_qgpto_#matraval#" class="badge bg-primary text-wrap" style="width: 4rem;">#form.meta1_qgpto#</div></label>
            <!---<cfset percent = ((rsAvalia.totaval * ptogrpitm) / (rsAvalia.totaval * ptogrpitm)) * 100>
            <cfset percent = numberFormat(percent,'___.00')> --->
            <label>&nbsp;Resultado: &nbsp;<div id="meta1_percqggitens_#matraval#" class="badge bg-primary text-wrap" style="width: 5rem;">#form.meta1_percqggitens#%</div></label>
        </div>
    </cfloop>  
 
    <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>Meta 2</strong>- INSP - Organizar 100% dos documentos gerados nas Avaliações de Controles realizadas, providenciado o arquivamento conforme critérios estabelecidos pela SGCIN/PE.  (Organizar documentos no SEI)</label>
    <cfloop query="rsAvalia">
        <cfset matraval = rsAvalia.RIP_MatricAvaliador>
        
        <cfquery datasource="#dsn_inspecao#" name="rsFacinInd">
            SELECT FFI_Meta2_Qtd_Item, FFI_Meta2_Pontuacao_Inicial, FFI_Meta2_Pontuacao_Obtida, FFI_Meta2_Resultado,FFI_Consideracao_Inspetor
            FROM UN_Ficha_Facin_Individual
            WHERE FFI_Avaliacao=convert(varchar,'#form.numinsp#') AND FFI_Avaliador='#rsAvalia.RIP_MatricAvaliador#' and FFI_Matricula = '#qAcesso.Usu_Matricula#'
        </cfquery>

        <cfset form.meta2_qggitens = #rsAvalia.totaval#>
        <cfset form.meta2_qgptop = (rsAvalia.totaval * ptogrpitm)>
        <cfset form.meta2_qgpto = (rsAvalia.totaval * ptogrpitm)>
        <cfset percent = ((rsAvalia.totaval * ptogrpitm) / (rsAvalia.totaval * ptogrpitm)) * 100>
        <cfset form.meta2_percqggitens = numberFormat(percent,'___.00')>
        
        <cfif rsFacinInd.recordcount gt 0>
            <cfset form.meta2_qggitens = #rsFacinInd.FFI_Meta2_Qtd_Item#>
            <cfset form.meta2_qgptop = #rsFacinInd.FFI_Meta2_Pontuacao_Inicial#>
            <cfset form.meta2_qgpto = #rsFacinInd.FFI_Meta2_Pontuacao_Obtida#>
            <cfset form.meta2_percqggitens = #rsFacinInd.FFI_Meta2_Resultado#>
        </cfif>        
        <div class="col-sm-4">
            <label for="" class="">&nbsp;#rsAvalia.Fun_Nome#</label>         
        </div>
        <div class="col-sm-8">
            <label>&nbsp;Qtd. Item Avaliado: &nbsp;<div id="meta2_qggitens_#matraval#" class="badge bg-primary text-wrap" style="width: 4rem;">#form.meta2_qggitens#</div></label>
            <label>&nbsp;Pontuação Inicial:&nbsp;<div id="meta2_qgptop_#matraval#" class="badge bg-primary text-wrap" style="width: 4rem;">#form.meta2_qgptop#</div></label>            
            <label>&nbsp;Pontuação Obtida:&nbsp;<div id="meta2_qgpto_#matraval#" class="badge bg-primary text-wrap" style="width: 4rem;">#form.meta2_qgpto#</div></label>
  <!---          <cfset percent = ((rsAvalia.totaval * ptogrpitm) / (rsAvalia.totaval * ptogrpitm)) * 100>
            <cfset percent = numberFormat(percent,'___.00')> --->
            <label>&nbsp;Resultado: &nbsp;<div id="meta2_percqggitens_#matraval#" class="badge bg-primary text-wrap" style="width: 5rem;">#form.meta2_percqggitens#%</div></label>
        </div>
    </cfloop>  
    <label for="" class="col-sm-12 col-form-label">&nbsp;<strong>Meta 3</strong> - Liberar 100% das Avaliações de Controle para revisão dentro do prazo estabelecido pela SGCIN/PE. (Liberar para revisão no prazo)</label>
    <label for="" class="col-sm-4 col-form-label">&nbsp;Data Transmissão Planejada:</label>
    <label for="" class="col-sm-4 col-form-label">&nbsp;Diferença(dia)</label>
    <label for="" class="col-sm-4 col-form-label">&nbsp;Percentual</label>
    <cfset form.meta3_dtplanej = ''>
    <cfset form.meta3_dif = 0>
    <cfset form.meta3_percent = 100>
    <cfif rsExisteFacin.recordcount gt 0>
        <cfset form.meta3_dtplanej = #rsExisteFacin.fac_data_plan_meta3#>
        <cfset form.meta3_dif = #int(rsExisteFacin.fac_difdia_meta3)#>
        <cfset form.meta3_percent = #rsExisteFacin.fac_perc_meta3#>
    </cfif>
    <label for="" class="col-sm-4 col-form-label"><input class="form-control" id="meta3_dtplanej" name="meta3_dtplanej" type="date" value="#form.meta3_dtplanej#" onKeyPress="numericos()" onKeyDown="Mascara_Data(this)" onblur="meta3(document.formx.concaval.value,this.value)" size="14" maxlength="10" placeholder="DD/MM/AAAA" #inspetorhd#></label>
    <label for="" class="col-sm-4 col-form-label"><div id="meta3_dif" class="badge bg-primary text-wrap" style="width: 4rem;">#form.meta3_dif#</div></label>
    <label for="" class="col-sm-4 col-form-label"><div id="meta3_percent" class="badge bg-primary text-wrap" style="width: 4rem;">#form.meta3_percent#%</div></label>
    <cfset auxcompl = 'Salvar Facin Grupo Acesso: ' & #grpacesso#>
    <cfif rsExisteFacin.recordcount gt 0>
        <cfset auxcompl = 'Salvar Facin (Grupo Acesso: ' & #grpacesso# & '    últ. atualiz.: ' & dateformat(rsExisteFacin.FAC_DtAlter,"DD/MM/YYYY") & ' ' & timeformat(rsExisteFacin.FAC_DtAlter,"HH:MM:SS") & ')'>
    </cfif>
    <cfset habsn = ''>
    <cfif rsExisteFacin.FAC_DtConcluirFacin neq ''>
        <cfset habsn = 'disabled'>
    </cfif>
    <input class="btn btn-primary" type="button" onclick="validarform()" value="<cfoutput>#auxcompl#</cfoutput>" #habsn#>
    <input class="btn btn-info" type="button" onClick="window.open('ficha_facin_Ref.cfm?numinsp=#form.numinsp#&acao=buscar','_self')" value="Voltar">
</div> 
<cfset meta1desconto = numberFormat((ptogrpitm/10),'___.0')>
<cfset meta2desconto = numberFormat((ptogrpitm/5),'___.0')>
<input type="hidden" id="meta1desconto" name="meta1desconto" value="#trim(meta1desconto)#">
<input type="hidden" id="meta2desconto" name="meta2desconto" value="#trim(meta2desconto)#">
<input type="hidden" id="totalNC" name="totalNC" value="#rsItem.recordcount#">
<input type="hidden" id="ptobtida" name="ptobtida" value="#ptogrpitm#">
<input type="hidden" id="matr_avaliador_pto" name="matr_avaliador_pto" value="#rsItem.RIP_MatricAvaliador#">
</cfoutput>    

</div>

<!--- </form> --->

<!--- <form name="formx" method="POST" action="cfc/fichafacin.cfc?method=salvarPosic" target="_self"> --->
    <cfoutput>
        <input type="hidden" name="facunidade" id="facunidade" value="#rsFicha.INP_Unidade#">
        <input type="hidden" name="facavaliacao" id="facavaliacao" value="#form.numinsp#">
        <input type="hidden" name="facmatricula" id="facmatricula" value="#trim(qAcesso.Usu_Matricula)#">
        <input type="hidden" name="facano" id="facano" value="#right(form.numinsp,4)#">
        <input type="hidden" name="facRevisor" id="facRevisor" value="#trim(rsFicha.matrrevisor)#">
        <input type="hidden" name="facdatasei" id="facdatasei" value="#dateformat(rsFicha.INP_DTConcluirAvaliacao,"YYYY-MM-DD")#">
        <input type="hidden" name="facqtdgeral" id="facqtdgeral" value="#form.ptogeral#">
        <input type="hidden" name="facqtdnc" id="facqtdnc" value="#rsItem.recordcount#">
        <input type="hidden" name="facqtdevolvido" id="facqtdevolvido" value="#form.ptodev#">
        <input type="hidden" name="facpontosrevisaometa1" id="facpontosrevisaometa1" value="#form.meta1#">
        <input type="hidden" name="facpercrevisaometa1" id="facpercrevisaometa1" value="#form.ptorevismeta1#">
        <input type="hidden" name="facpontosrevisaometa2" id="facpontosrevisaometa2" value="#form.meta2#">
        <input type="hidden" name="facpercrevisaometa2" id="facpercrevisaometa2" value="#form.ptorevismeta2#">
        <input type="hidden" name="facdataplanmeta3" id="facdataplanmeta3" value="#form.meta3_dtplanej#">
        <input type="hidden" name="facdifdiameta3" id="facdifdiameta3" value="#form.meta3_dif#">
        <input type="hidden" name="facpercmeta3" id="facpercmeta3" value="#form.meta3_percent#">
        <input type="hidden" name="facmeta1pesoitem" id="facmeta1pesoitem" value="#trim(meta1desconto)#">
        <input type="hidden" name="facmeta2pesoitem" id="facmeta2pesoitem" value="#trim(meta2desconto)#">
        <input type="hidden" name="facagrupo" id="facagrupo" value="#grp#">
        <input type="hidden" name="facaitem" id="facaitem" value="#itm#">
        <input type="hidden" id="somenteavaliarmeta3" name="somenteavaliarmeta3" value="#form.somenteavaliarmeta3#">
             
        
    <cfloop query="rsAvalia">
        <cfquery datasource="#dsn_inspecao#" name="rsFacinInd">
            SELECT FFI_Meta1_Qtd_Item, FFI_Meta1_Pontuacao_Inicial, FFI_Meta1_Pontuacao_Obtida, FFI_Meta1_Resultado,FFI_Meta2_Qtd_Item, FFI_Meta2_Pontuacao_Inicial, FFI_Meta2_Pontuacao_Obtida, FFI_Meta2_Resultado,FFI_Consideracao_Inspetor
            FROM UN_Ficha_Facin_Individual
            WHERE FFI_Avaliacao=convert(varchar,'#form.numinsp#') AND FFI_Avaliador='#rsAvalia.RIP_MatricAvaliador#'
        </cfquery>
        <!--- meta1 --->
        <cfset form.meta1_qggitens = #rsAvalia.totaval#>
        <cfset form.meta1_qgptop = (rsAvalia.totaval * ptogrpitm)>
        <cfset form.meta1_qgpto = (rsAvalia.totaval * ptogrpitm)>
        <cfset percent = ((rsAvalia.totaval * ptogrpitm) / (rsAvalia.totaval * ptogrpitm)) * 100>
        <cfset form.meta1_percqggitens = numberFormat(percent,'___.00')>
        <!--- meta2 --->
        <cfset form.meta2_qggitens = #rsAvalia.totaval#>
        <cfset form.meta2_qgptop = (rsAvalia.totaval * ptogrpitm)>
        <cfset form.meta2_qgpto = (rsAvalia.totaval * ptogrpitm)>
        <cfset percent = ((rsAvalia.totaval * ptogrpitm) / (rsAvalia.totaval * ptogrpitm)) * 100>
        <cfset form.meta2_percqggitens = numberFormat(percent,'___.00')>
        
        <cfif rsFacinInd.recordcount gt 0>
            <!--- meta1 --->
            <cfset form.meta1_qggitens = #rsFacinInd.FFI_Meta1_Qtd_Item#>
            <cfset form.meta1_qgptop = #rsFacinInd.FFI_Meta1_Pontuacao_Inicial#>
            <cfset form.meta1_qgpto = #rsFacinInd.FFI_Meta1_Pontuacao_Obtida#>
            <cfset form.meta1_percqggitens = #rsFacinInd.FFI_Meta1_Resultado#>
            <!--- meta2 --->
            <cfset form.meta2_qggitens = #rsFacinInd.FFI_Meta2_Qtd_Item#>
            <cfset form.meta2_qgptop = #rsFacinInd.FFI_Meta2_Pontuacao_Inicial#>
            <cfset form.meta2_qgpto = #rsFacinInd.FFI_Meta2_Pontuacao_Obtida#>
            <cfset form.meta2_percqggitens = #rsFacinInd.FFI_Meta2_Resultado#>
        </cfif>   
<!---   
        <cfset percent = ((rsAvalia.totaval * ptogrpitm) / (rsAvalia.totaval * ptogrpitm)) * 100>
        <cfset percent = numberFormat(percent,'___.00')> 
--->
        <!--- meta1 --->
        <input type="hidden" name="ffimeta1qtditem_#rsAvalia.RIP_MatricAvaliador#" id="ffimeta1qtditem_#rsAvalia.RIP_MatricAvaliador#" value="#form.meta1_qggitens#">
        <input type="hidden" name="ffimeta1pontuacaoinicial_#rsAvalia.RIP_MatricAvaliador#" id="ffimeta1pontuacaoinicial_#rsAvalia.RIP_MatricAvaliador#" value="#form.meta1_qgptop#">
        <input type="hidden" name="ffimeta1pontuacaoobtida_#rsAvalia.RIP_MatricAvaliador#" id="ffimeta1pontuacaoobtida_#rsAvalia.RIP_MatricAvaliador#" value="#form.meta1_qgpto#">
        <input type="hidden" name="ffimeta1resultado_#rsAvalia.RIP_MatricAvaliador#" id="ffimeta1resultado_#rsAvalia.RIP_MatricAvaliador#" value="#form.meta1_percqggitens#">
        <input type="hidden" name="db_ptobtidameta1_#rsAvalia.RIP_MatricAvaliador#" id="db_ptobtidameta1_#rsAvalia.RIP_MatricAvaliador#" value="#form.meta1_qgpto#">
        <input type="hidden" name="db_Resultadometa1_#rsAvalia.RIP_MatricAvaliador#" id="db_Resultadometa1_#rsAvalia.RIP_MatricAvaliador#" value="#form.meta1_percqggitens#">
        <input type="hidden" name="db_meta1" id="db_meta1" value="#form.meta1#">
        <input type="hidden" name="db_ptorevismeta1" id="db_ptorevismeta1" value="#form.ptorevismeta1#">

        <!--- meta2 --->
        <input type="hidden" name="ffimeta2qtditem_#rsAvalia.RIP_MatricAvaliador#" id="ffimeta2qtditem_#rsAvalia.RIP_MatricAvaliador#" value="#form.meta2_qggitens#">
        <input type="hidden" name="ffimeta2pontuacaoinicial_#rsAvalia.RIP_MatricAvaliador#" id="ffimeta2pontuacaoinicial_#rsAvalia.RIP_MatricAvaliador#" value="#form.meta2_qgptop#">
        <input type="hidden" name="ffimeta2pontuacaoobtida_#rsAvalia.RIP_MatricAvaliador#" id="ffimeta2pontuacaoobtida_#rsAvalia.RIP_MatricAvaliador#" value="#form.meta2_qgpto#">
        <input type="hidden" name="ffimeta2resultado_#rsAvalia.RIP_MatricAvaliador#" id="ffimeta2resultado_#rsAvalia.RIP_MatricAvaliador#" value="#form.meta2_percqggitens#">
        <input type="hidden" name="db_ptobtidameta2_#rsAvalia.RIP_MatricAvaliador#" id="db_ptobtidameta2_#rsAvalia.RIP_MatricAvaliador#" value="#form.meta2_qgpto#">
        <input type="hidden" name="db_Resultadometa2_#rsAvalia.RIP_MatricAvaliador#" id="db_Resultadometa2_#rsAvalia.RIP_MatricAvaliador#" value="#form.meta2_percqggitens#">
        <input type="hidden" name="db_meta2" id="db_meta2" value="#form.meta2#">
        <input type="hidden" name="db_ptorevismeta2" id="db_ptorevismeta2" value="#form.ptorevismeta2#">
    </cfloop>  
    <cfloop query="rsItem">
        <cfset grpitm = rsItem.Itn_NumGrupo & '_' & rsItem.Itn_NumItem>
        <cfset form.meta1_pto = #ptogrpitm#>
        <cfset form.meta2_pto = #ptogrpitm#>
        <cfif rsItem.FACA_Avaliacao neq ''>
            <cfset form.meta1_pto = #FACA_Meta1_Pontos#>
            <cfset form.meta2_pto = #FACA_Meta2_Pontos#>
        </cfif>    
        <input type="hidden" name="facaavaliador" id="facaavaliador" value="#rsItem.RIP_MatricAvaliador#">
        <input type="hidden" name="facameta1pontos" id="facameta1pontos" value="#form.meta1_pto#">
        <input type="hidden" name="facameta2pontos" id="facameta2pontos" value="#form.meta2_pto#">
        <cfif FACA_Avaliacao neq ''>
            <input type="hidden" name="meta1_atorgr" class="meta1_atorgr" value="<cfoutput>#rsItem.FACA_Meta1_AT_OrtoGram#</cfoutput>">
            <input type="hidden" name="meta1_atcccp" class="meta1_atcccp" value="<cfoutput>#rsItem.FACA_Meta1_AT_CCCP#</cfoutput>">
            <input type="hidden" name="meta1_aetecn" class="meta1_aetecn" value="<cfoutput>#rsItem.FACA_Meta1_AE_Tecn#</cfoutput>"> 
            <input type="hidden" name="meta1_aeprob" class="meta1_aeprob" value="<cfoutput>#rsItem.FACA_Meta1_AE_Prob#</cfoutput>">
            <input type="hidden" name="meta1_aevalo" class="meta1_aevalo" value="<cfoutput>#rsItem.FACA_Meta1_AE_Valor#</cfoutput>">
            <input type="hidden" name="meta1_aecsqc" class="meta1_aecsqc" value="<cfoutput>#rsItem.FACA_Meta1_AE_Cosq#</cfoutput>">
            <input type="hidden" name="meta1_aenorm" class="meta1_aenorm" value="<cfoutput>#rsItem.FACA_Meta1_AE_Norma#</cfoutput>">
            <input type="hidden" name="meta1_aedocm" class="meta1_aedocm" value="<cfoutput>#rsItem.FACA_Meta1_AE_Docu#</cfoutput>">
            <input type="hidden" name="meta1_aeclas" class="meta1_aeclas" value="<cfoutput>#rsItem.FACA_Meta1_AE_Class#</cfoutput>">
            <input type="hidden" name="meta1_orient" class="meta1_orient" value="<cfoutput>#rsItem.FACA_Meta1_AE_Orient#</cfoutput>">
            <input type="hidden" name="meta2_arfalt" class="meta2_arfalt" value="<cfoutput>#rsItem.FACA_Meta2_AR_Falta#</cfoutput>">
            <input type="hidden" name="meta2_artroc" class="meta2_artroc" value="<cfoutput>#rsItem.FACA_Meta2_AR_Troca#</cfoutput>">
            <input type="hidden" name="meta2_arnomc" class="meta2_arnomc" value="<cfoutput>#rsItem.FACA_Meta2_AR_Nomen#</cfoutput>">
            <input type="hidden" name="meta2_arorde" class="meta2_arorde" value="<cfoutput>#rsItem.FACA_Meta2_AR_Ordem#</cfoutput>">
            <input type="hidden" name="meta2_arpraz" class="meta2_arpraz" value="<cfoutput>#rsItem.FACA_Meta2_AR_Prazo#</cfoutput>">  
        <cfelse>
            <input type="hidden" name="meta1_atorgr" class="meta1_atorgr" value="0">
            <input type="hidden" name="meta1_atcccp" class="meta1_atcccp" value="0">
            <input type="hidden" name="meta1_aetecn" class="meta1_aetecn" value="0"> 
            <input type="hidden" name="meta1_aeprob" class="meta1_aeprob" value="0">
            <input type="hidden" name="meta1_aevalo" class="meta1_aevalo" value="0">
            <input type="hidden" name="meta1_aecsqc" class="meta1_aecsqc" value="0">
            <input type="hidden" name="meta1_aenorm" class="meta1_aenorm" value="0">
            <input type="hidden" name="meta1_aedocm" class="meta1_aedocm" value="0">
            <input type="hidden" name="meta1_aeclas" class="meta1_aeclas" value="0">
            <input type="hidden" name="meta1_orient" class="meta1_orient" value="0">
            <input type="hidden" name="meta2_arfalt" class="meta2_arfalt" value="0">
            <input type="hidden" name="meta2_artroc" class="meta2_artroc" value="0">
            <input type="hidden" name="meta2_arnomc" class="meta2_arnomc" value="0">
            <input type="hidden" name="meta2_arorde" class="meta2_arorde" value="0">
            <input type="hidden" name="meta2_arpraz" class="meta2_arpraz" value="0">              
        </cfif>        
    </cfloop>
        <input type="hidden" id="grpacesso" name="grpacesso" value="#grpacesso#">
        <input type="hidden" id="FFIConsideracaoInspetor" name="FFIConsideracaoInspetor" value="#rsFacinInd.FFI_Consideracao_Inspetor#">
        <input type="hidden" name="grp" id="grp" value="#grp#">
        <input type="hidden" name="itm" id="itm" value="#itm#">
        <input type="hidden" name="matravaliador" id="matravaliador" value="#rsItem.RIP_MatricAvaliador#">      
    </cfoutput>
</form>
</body>


<script src="public/bootstrap/bootstrap.bundle.min.js"></script>
<script src="public/jquery-3.7.1.min.js"></script>
<script>
$(function(e){
    //alert('Dom inicializado!');   
    if($('#grpacesso').val() == 'INSPETORES') {
        $('#considerar').val($('#FFIConsideracaoInspetor').val())
    }
})
//<input type="hidden" id="grpacesso" name="grpacesso" value="#grpacesso#">
//<input type="hidden" id="FFIConsideracaoInspetor" name="FFIConsideracaoInspetor" value="#rsFacinInd.FFI_Consideracao_Inspetor#">

//=============================================================
        function consideracao(a,b){
           //alert($("#considerar").val());
           $("#facconsideracao").val(b);
           // alert(a + '  ' + b + '  ' + $("#facaconsideracaoavaliador_702_3").val());
        }  

//=======================================================================
   function validarform(){
        if (document.formx.meta3_dtplanej.value==''){
            alert("Falta informar o campo: Data Transmissão Planejada!");
            document.formx.meta3_dtplanej.focus();
            return false;
        }
        
        if (document.formx.considerar.value == '' && document.formx.somenteavaliarmeta3.value == 'N'){
            alert("Falta informar as suas considerações do Item selecionado!");
            $('.accordion-button').trigger('click');
            $('#considerar').focus();
            return false;
        }   
                    
        document.formx.submit();  
   }
 // ================================================================  
    //verificar seleções meta1 e ajustar a pontuação obtida
    $('.meta1').click(function(){     
        let ptometa1 = $('#meta1_pto_obtida').val()
        let ptobtida = $('#ptobtida').val()
        let meta1desconto = $('#meta1desconto').val()  
    // alert(' meta1desconto:'+meta1desconto+' ptometa1:'+ptometa1+'  ptobtida:'+ptobtida);
    
        let totcheckded=0
        $( ".meta1" ).each(function( index ) {
            auxnome = $(this).attr("id")
            if($(this).is(':checked')) {
                totcheckded++
                $('.'+auxnome).val(1)
            }else{
                $('.'+auxnome).val(0)
            }
           // alert($('.'+auxnome).val())
        })
        
        //atualizar Pontuação Obtida por avaliador/Grupo_Item
        let novaptobtd = ptobtida;
        if(totcheckded > 0){
            novaptobtd = eval(ptobtida - (totcheckded*meta1desconto)).toFixed(2)
            $('#meta1_pto_obtida').val(novaptobtd)
        }else{
            $('#meta1_pto_obtida').val(novaptobtd) 
        }
    //alert('novaptobtd: '+novaptobtd)

    // ajustar 09.Individualização do resultado das metas por inspetor (a ser preenchido pela equipe de inspetores):
        let matraval=$("#matr_avaliador_pto").val() 
        let dbptobtidameta1 = $('#db_ptobtidameta1_' + matraval).val();
        let dbResultadometa1 = $('#db_Resultadometa1_' + matraval).val();
        if(totcheckded > 0){
            let pontosobtidosatual = $('#meta1_qgpto_' + matraval).html();
            let pontuacaoinicial= $('#meta1_qgptop_' + matraval).html(); 
            let desconto = eval(totcheckded*meta1desconto).toFixed(2) 
            let novopontoobtido = eval(pontosobtidosatual - desconto).toFixed(2)
            $('#meta1_qgpto_' + matraval).html(novopontoobtido);
            $("#ffimeta1pontuacaoobtida_" + matraval).val(novopontoobtido)
            let percmeta1 = parseFloat((novopontoobtido / pontuacaoinicial)*100).toFixed(2);
            $('#meta1_percqggitens_' + matraval).html(percmeta1 + ' %');
            $("#ffimeta1resultado_" + matraval).val(percmeta1)
        }else{
            $('#meta1_qgpto_' + matraval).html(dbptobtidameta1);
            $("#ffimeta1pontuacaoobtida_" + matraval).val(dbptobtidameta1)
            $('#meta1_percqggitens_' + matraval).html(dbResultadometa1 + ' %');
            $("#ffimeta1resultado_" + matraval).val(dbResultadometa1)
        }
    // FIM  ajustar 09.Individualização do resultado das metas por inspetor (a ser preenchido pela equipe de inspetores):
    // ajustar 04.Avaliação
            let facqtdgeral = '';
            let dbmeta1= ''; 
            let dbptorevismeta1= ''; 
            facqtdgeral = $('#facqtdgeral').val();
            dbmeta1= $('#db_meta1').val(); 
            dbptorevismeta1= $('#db_ptorevismeta1').val(); 
            
            let novoptorevismeta1 = eval(facqtdgeral - (totcheckded*meta1desconto)).toFixed(2)
            let percmeta1 = parseFloat((novoptorevismeta1/facqtdgeral)*100).toFixed(2);
            if(totcheckded > 0){
                $('#ptorevismeta1').html(novoptorevismeta1);
                $('#meta1').html(percmeta1 + ' %');
                $('#facpontosrevisaometa1').val(novoptorevismeta1);
                $('#facpercrevisaometa1').val(percmeta1);
            }else{
                $('#ptorevismeta1').html(dbptorevismeta1);
                $('#meta1').html(dbmeta1 + ' %');    
                $('#facpontosrevisaometa1').val(dbptorevismeta1);
                $('#facpercrevisaometa1').val(dbmeta1);    
            }
    // fim ajustar 04.Avaliação
    })

    //verificar seleções meta2 e ajustar a pontuação obtida
    $('.meta2').click(function(){     
        let ptometa2 = $('#meta2_pto_obtida').val()
        let ptobtida = $('#ptobtida').val()
        let meta2desconto = $('#meta2desconto').val()         
    // alert(' meta2desconto:'+meta2desconto+' ptometa2:'+ptometa2+'  ptobtida:'+ptobtida);
    
        let totcheckded=0
        $( ".meta2" ).each(function( index ) {
            auxnome = $(this).attr("id")
            if($(this).is(':checked')) {
                totcheckded++
                $('.'+auxnome).val(1)
            }else{
                $('.'+auxnome).val(0)
            }
        })
        //atualizar Pontuação Obtida por avaliador/Grupo_Item
        if(totcheckded > 0){
            let novaptobtd = eval(ptobtida - (totcheckded*meta2desconto)).toFixed(2)
            $('#meta2_pto_obtida').val(novaptobtd)
        }else{
            $('#meta2_pto_obtida').val(ptobtida) 
        }
    //alert('novaptobtd: '+novaptobtd)
    // ajustar 09.Individualização do resultado das metas por inspetor (a ser preenchido pela equipe de inspetores):
        let matraval=$("#matr_avaliador_pto").val() 
        let dbptobtidameta2 = $('#db_ptobtidameta2_' + matraval).val();
        let dbResultadometa2 = $('#db_Resultadometa2_' + matraval).val();
        if(totcheckded > 0){
            let pontosobtidosatual = $('#meta2_qgpto_' + matraval).html();
            let pontuacaoinicial= $('#meta2_qgptop_' + matraval).html(); 
            let desconto = eval(totcheckded*meta2desconto).toFixed(2) 
            let novopontoobtido = eval(pontosobtidosatual - desconto).toFixed(2)
            $('#meta2_qgpto_' + matraval).html(novopontoobtido);
            $("#ffimeta2pontuacaoobtida_" + matraval).val(novopontoobtido)   
            let percmeta2 = parseFloat((novopontoobtido / pontuacaoinicial)*100).toFixed(2);
            $('#meta2_percqggitens_' + matraval).html(percmeta2 + ' %');
            $("#ffimeta2resultado_" + matraval).val(percmeta2)
        }else{
                $('#meta2_qgpto_' + matraval).html(dbptobtidameta2);
                $("#ffimeta2pontuacaoobtida_" + matraval).val(dbptobtidameta2)
                $('#meta2_percqggitens_' + matraval).html(dbResultadometa2 + ' %');
                $("#ffimeta2resultado_" + matraval).val(dbResultadometa2)                
            }        
    // FIM  ajustar 09.Individualização do resultado das metas por inspetor (a ser preenchido pela equipe de inspetores):
    // ajustar 04.Avaliação
        let facqtdgeral ='';
        let dbmeta2= '';           
        let dbptorevismeta2= '';        
        facqtdgeral = $('#facqtdgeral').val();
        dbmeta2= $('#db_meta2').val();           
        dbptorevismeta2= $('#db_ptorevismeta2').val();      

        let novoptorevismeta2 = eval(facqtdgeral - (totcheckded*meta2desconto)).toFixed(2)
        let percmeta2 = parseFloat((novoptorevismeta2/facqtdgeral)*100).toFixed(2);
        if(totcheckded > 0){
            $('#ptorevismeta2').html(novoptorevismeta2);
            $('#meta2').html(percmeta2 + ' %');
            $('#facpontosrevisaometa2').val(novoptorevismeta2);
            $('#facpercrevisaometa2').val(percmeta2);
        }else{
            $('#ptorevismeta2').html(dbptorevismeta2);
            $('#meta2').html(dbmeta2 + ' %');    
            $('#facpontosrevisaometa2').val(dbptorevismeta2);
            $('#facpercrevisaometa2').val(dbmeta2);                
        }
    // fim ajustar 04.Avaliação
})    
//*****************************************************************
</script>
     
</html>
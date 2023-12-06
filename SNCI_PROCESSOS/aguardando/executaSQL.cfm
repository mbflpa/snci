<cfquery datasource="#application.dsn_processos#" >
    update pc_orgaos set pc_org_se_abrangencia ='10,06,16,28,26,75,65,05,03'
    where pc_orgaos.pc_org_mcu in('00437382','00437394')

    update pc_orgaos set pc_org_se_abrangencia ='20,08,14'
    where pc_orgaos.pc_org_mcu in('00437384','00437396')

    update pc_orgaos set pc_org_se_abrangencia ='36,64,68' 
    where pc_orgaos.pc_org_mcu in('00437388','00437400')

    update pc_orgaos set pc_org_se_abrangencia ='74,24,22'
    where pc_orgaos.pc_org_mcu in('00437392','00437404')

    update pc_orgaos set pc_org_se_abrangencia ='72,50'
    where pc_orgaos.pc_org_mcu in('00437390','00437402')

    UPDATE pc_perfil_tipos set 
    pc_perfil_tipo_descricao = 'CI - REGIONAL - SCIA - Acompanhamento',
    pc_perfil_tipo_status ='A',
    pc_perfil_tipo_comentario ='SCIA - Visualiza todos os processos cujos órgão avaliados estão sob gestão da sua SE de lotação.'
    where pc_perfil_tipo_id =14


</cfquery>


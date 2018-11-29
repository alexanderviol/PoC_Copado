/*
Wrapper class for passing complaints data to USFDA
@author	Mike Tribble
@revised 07/13/18 created
*/
public with sharing class X5500_EMDR {

	public String mdrid;
	public String a1_patient_identifier;
	public String a2_patient_dob;
	public String a3_patient_gender;
	public String a3_patient_weight;
	public String a5_patient_ethnicgroup;
	public String a5_patient_racecode_asian;
	public String a5_patient_racecode_amindian;
	public String a5_patient_racecode_black;
	public String a5_patient_racecode_white;
	public String a5_patient_racecode_pacisland;
	public String b1_adverse_event;
	public String b1_product_problem;
	public String b2_adverse_event_death;
	public String b2_adverse_event_life_threat;
	public String b2_adverse_event_hospital;
	public String b2_adverse_event_req_intervent;
	public String b2_adverse_event_disability;
	public String b2_adverse_event_cong_anomaly;
	public String b2_adverse_event_other;
	public String b2_adverse_event_death_date;
	public String b3_date_of_event;
	public String b4_date_of_this_report;
	public String b5_describe_event_of_problem;
	public String d1_brand_name;
	public String d2_common_device_name;
	public String d2_common_device_name_pcode;
	public String d3_manufacturer_name;
	public String d3_manufacturer_street_line_1;
	public String d3_manufacturer_city;
	public String d3_manufacturer_state_code;
	public String d3_manufacturer_zip_code;
	public String d3_manufacturer_country_code;
	public String d4_model_number;
	public String d4_lot_number;
	public String d4_expiration_date;
	public String d4_serial_number;
	public String d4_other_number;
	public String d4_udi_number;
	public String d6_if_implanted_give_date;
	public String d7_if_explanted_give_date;
	public String d10_avail_for_evaluation;
	public String d10_avail_for_evaluation_date;
	public String e1_organization_name;
	public String e1_name_given_1;
	public String e1_name_family;
	public String e1_street_line_1;
	public String e1_city;
	public String e1_state_code;
	public String e1_zip_code;
	public String e1_country_code;
	public String e2_health_professional;
	public String e3_occupation;
	public String e4_also_sent_report_to_fda;
	public String f10_codes_patient_code_1;
	public String f10_codes_patient_code_2;
	public String f10_codes_patient_code_3;
	public String f10_codes_device_code_1;
	public String f10_codes_device_code_2;
	public String f10_codes_device_code_3;
	public String g1_contact_facility_name;
	public String g1_contact_street_line_1;
	public String g1_contact_city;
	public String g1_contact_state_code;
	public String g1_contact_zip_code;
	public String g1_contact_country_code;
	public String g1_contact_telecom_1;
	public String g3_report_src_foreign;
	public String g3_report_src_study;
	public String g3_report_src_literature;
	public String g3_report_src_consumer;
	public String g3_report_src_health_prof;
	public String g3_report_src_user_facility;
	public String g3_report_src_company_rep;
	public String g3_report_src_distributor;
	public String g3_report_src_other;
	public String g4_received_by_manuf_date;
	public String g5_pma_number;
	public String g7_type_of_report_5day;
	public String g7_type_of_report_7day;
	public String g7_type_of_report_10day;
	public String g7_type_of_report_15day;
	public String g7_type_of_report_30day;
	public String g7_type_of_report_periodic;
	public String g7_type_of_report_initial;
	public String g7_type_of_report_followup;
	public String g7_type_of_report_followup_num;
	public String g9_manufacturer_report_number;
	public String h1_type_of_report_event;
	public String h2_type_correction;
	public String h2_type_additional_information;
	public String h2_type_response_fda_request;
	public String h2_type_device_evaluation;
	public String h3_device_eval_by_manufacturer;
	public String h3_eval_summary_attached;
	public String h3_reason_for_non_eval_code;
	public String h3_reason_for_non_eval;
	public String h4_device_manufacture_date;
	public String h5_labeled_for_single_use;
	public String h6_evaluation_codes_method_1;
	public String h6_evaluation_codes_method_2;
	public String h6_evaluation_codes_method_3;
	public String h6_evaluation_codes_method_4;
	public String h6_evaluation_codes_results_1;
	public String h6_evaluation_codes_results_2;
	public String h6_evaluation_codes_results_3;
	public String h6_evaluation_codes_results_4;
	public String h6_evaluation_codes_conclusn_1;
	public String h6_evaluation_codes_conclusn_2;
	public String h6_evaluation_codes_conclusn_3;
	public String h6_evaluation_codes_conclusn_4;
	public String h7_remedial_action_init;
	public String h8_usage_of_device;
	public String h9_corrective_action_number;
	public String h10_additional_narrative;
	public String h11_corrected_data;
	private String[] mdrid_type_info = new String[]{'mdrid','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] a1_patient_identifier_type_info = new String[]{'a1_patient_identifier','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] a2_patient_dob_type_info = new String[]{'a2_patient_dob','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] a3_patient_gender_type_info = new String[]{'a3_patient_gender','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] a3_patient_weight_type_info = new String[]{'a3_patient_weight','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] a5_patient_ethnicgroup_type_info = new String[]{'a5_patient_ethnicgroup','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] a5_patient_racecode_asian_type_info = new String[]{'a5_patient_racecode_asian','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] a5_patient_racecode_amindian_type_info = new String[]{'a5_patient_racecode_amindian','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] a5_patient_racecode_black_type_info = new String[]{'a5_patient_racecode_black','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] a5_patient_racecode_white_type_info = new String[]{'a5_patient_racecode_white','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] a5_patient_racecode_pacisland_type_info = new String[]{'a5_patient_racecode_pacisland','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] b1_adverse_event_type_info = new String[]{'b1_adverse_event','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] b1_product_problem_type_info = new String[]{'b1_product_problem','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] b2_adverse_event_death_type_info = new String[]{'b2_adverse_event_death','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] b2_adverse_event_life_threat_type_info = new String[]{'b2_adverse_event_life_threat','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] b2_adverse_event_hospital_type_info = new String[]{'b2_adverse_event_hospital','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] b2_adverse_event_req_intervent_type_info = new String[]{'b2_adverse_event_req_intervent','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] b2_adverse_event_disability_type_info = new String[]{'b2_adverse_event_disability','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] b2_adverse_event_cong_anomaly_type_info = new String[]{'b2_adverse_event_cong_anomaly','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] b2_adverse_event_other_type_info = new String[]{'b2_adverse_event_other','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] b2_adverse_event_death_date_type_info = new String[]{'b2_adverse_event_death_date','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] b3_date_of_event_type_info = new String[]{'b3_date_of_event','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] b4_date_of_this_report_type_info = new String[]{'b4_date_of_this_report','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] b5_describe_event_of_problem_type_info = new String[]{'b5_describe_event_of_problem','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] d1_brand_name_type_info = new String[]{'d1_brand_name','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] d2_common_device_name_type_info = new String[]{'d2_common_device_name','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] d2_common_device_name_pcode_type_info = new String[]{'d2_common_device_name_pcode','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] d3_manufacturer_name_type_info = new String[]{'d3_manufacturer_name','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] d3_manufacturer_street_line_1_type_info = new String[]{'d3_manufacturer_street_line_1','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] d3_manufacturer_city_type_info = new String[]{'d3_manufacturer_city','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] d3_manufacturer_state_code_type_info = new String[]{'d3_manufacturer_state_code','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] d3_manufacturer_zip_code_type_info = new String[]{'d3_manufacturer_zip_code','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] d3_manufacturer_country_code_type_info = new String[]{'d3_manufacturer_country_code','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] d4_model_number_type_info = new String[]{'d4_model_number','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] d4_lot_number_type_info = new String[]{'d4_lot_number','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] d4_expiration_date_type_info = new String[]{'d4_expiration_date','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] d4_serial_number_type_info = new String[]{'d4_serial_number','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] d4_other_number_type_info = new String[]{'d4_other_number','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] d4_udi_number_type_info = new String[]{'d4_udi_number','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] d6_if_implanted_give_date_type_info = new String[]{'d6_if_implanted_give_date','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] d7_if_explanted_give_date_type_info = new String[]{'d7_if_explanted_give_date','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] d10_avail_for_evaluation_type_info = new String[]{'d10_avail_for_evaluation','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] d10_avail_for_evaluation_date_type_info = new String[]{'d10_avail_for_evaluation_date','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] e1_organization_name_type_info = new String[]{'e1_organization_name','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] e1_name_given_1_type_info = new String[]{'e1_name_given_1','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] e1_name_family_type_info = new String[]{'e1_name_family','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] e1_street_line_1_type_info = new String[]{'e1_street_line_1','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] e1_city_type_info = new String[]{'e1_city','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] e1_state_code_type_info = new String[]{'e1_state_code','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] e1_zip_code_type_info = new String[]{'e1_zip_code','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] e1_country_code_type_info = new String[]{'e1_country_code','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] e2_health_professional_type_info = new String[]{'e2_health_professional','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] e3_occupation_type_info = new String[]{'e3_occupation','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] e4_also_sent_report_to_fda_type_info = new String[]{'e4_also_sent_report_to_fda','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] f10_codes_patient_code_1_type_info = new String[]{'f10_codes_patient_code_1','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] f10_codes_patient_code_2_type_info = new String[]{'f10_codes_patient_code_2','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] f10_codes_patient_code_3_type_info = new String[]{'f10_codes_patient_code_3','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] f10_codes_device_code_1_type_info = new String[]{'f10_codes_device_code_1','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] f10_codes_device_code_2_type_info = new String[]{'f10_codes_device_code_2','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] f10_codes_device_code_3_type_info = new String[]{'f10_codes_device_code_3','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g1_contact_facility_name_type_info = new String[]{'g1_contact_facility_name','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g1_contact_street_line_1_type_info = new String[]{'g1_contact_street_line_1','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g1_contact_city_type_info = new String[]{'g1_contact_city','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g1_contact_state_code_type_info = new String[]{'g1_contact_state_code','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g1_contact_zip_code_type_info = new String[]{'g1_contact_zip_code','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g1_contact_country_code_type_info = new String[]{'g1_contact_country_code','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g1_contact_telecom_1_type_info = new String[]{'g1_contact_telecom_1','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g3_report_src_foreign_type_info = new String[]{'g3_report_src_foreign','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g3_report_src_study_type_info = new String[]{'g3_report_src_study','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g3_report_src_literature_type_info = new String[]{'g3_report_src_literature','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g3_report_src_consumer_type_info = new String[]{'g3_report_src_consumer','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g3_report_src_health_prof_type_info = new String[]{'g3_report_src_health_prof','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g3_report_src_user_facility_type_info = new String[]{'g3_report_src_user_facility','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g3_report_src_company_rep_type_info = new String[]{'g3_report_src_company_rep','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g3_report_src_distributor_type_info = new String[]{'g3_report_src_distributor','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g3_report_src_other_type_info = new String[]{'g3_report_src_other','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g4_received_by_manuf_date_type_info = new String[]{'g4_received_by_manuf_date','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g5_pma_number_type_info = new String[]{'g5_pma_number','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g7_type_of_report_5day_type_info = new String[]{'g7_type_of_report_5day','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g7_type_of_report_7day_type_info = new String[]{'g7_type_of_report_7day','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g7_type_of_report_10day_type_info = new String[]{'g7_type_of_report_10day','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g7_type_of_report_15day_type_info = new String[]{'g7_type_of_report_15day','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g7_type_of_report_30day_type_info = new String[]{'g7_type_of_report_30day','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g7_type_of_report_periodic_type_info = new String[]{'g7_type_of_report_periodic','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g7_type_of_report_initial_type_info = new String[]{'g7_type_of_report_initial','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g7_type_of_report_followup_type_info = new String[]{'g7_type_of_report_followup','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g7_type_of_report_followup_num_type_info = new String[]{'g7_type_of_report_followup_num','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] g9_manufacturer_report_number_type_info = new String[]{'g9_manufacturer_report_number','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h1_type_of_report_event_type_info = new String[]{'h1_type_of_report_event','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h2_type_correction_type_info = new String[]{'h2_type_correction','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h2_type_additional_information_type_info = new String[]{'h2_type_additional_information','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h2_type_response_fda_request_type_info = new String[]{'h2_type_response_fda_request','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h2_type_device_evaluation_type_info = new String[]{'h2_type_device_evaluation','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h3_device_eval_by_manufacturer_type_info = new String[]{'h3_device_eval_by_manufacturer','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h3_eval_summary_attached_type_info = new String[]{'h3_eval_summary_attached','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h3_reason_for_non_eval_code_type_info = new String[]{'h3_reason_for_non_eval_code','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h3_reason_for_non_eval_type_info = new String[]{'h3_reason_for_non_eval','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h4_device_manufacture_date_type_info = new String[]{'h4_device_manufacture_date','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h5_labeled_for_single_use_type_info = new String[]{'h5_labeled_for_single_use','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h6_evaluation_codes_method_1_type_info = new String[]{'h6_evaluation_codes_method_1','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h6_evaluation_codes_method_2_type_info = new String[]{'h6_evaluation_codes_method_2','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h6_evaluation_codes_method_3_type_info = new String[]{'h6_evaluation_codes_method_3','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h6_evaluation_codes_method_4_type_info = new String[]{'h6_evaluation_codes_method_4','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h6_evaluation_codes_results_1_type_info = new String[]{'h6_evaluation_codes_results_1','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h6_evaluation_codes_results_2_type_info = new String[]{'h6_evaluation_codes_results_2','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h6_evaluation_codes_results_3_type_info = new String[]{'h6_evaluation_codes_results_3','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h6_evaluation_codes_results_4_type_info = new String[]{'h6_evaluation_codes_results_4','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h6_evaluation_codes_conclusn_1_type_info = new String[]{'h6_evaluation_codes_conclusn_1','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h6_evaluation_codes_conclusn_2_type_info = new String[]{'h6_evaluation_codes_conclusn_2','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h6_evaluation_codes_conclusn_3_type_info = new String[]{'h6_evaluation_codes_conclusn_3','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h6_evaluation_codes_conclusn_4_type_info = new String[]{'h6_evaluation_codes_conclusn_4','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h7_remedial_action_init_type_info = new String[]{'h7_remedial_action_init','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h8_usage_of_device_type_info = new String[]{'h8_usage_of_device','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h9_corrective_action_number_type_info = new String[]{'h9_corrective_action_number','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h10_additional_narrative_type_info = new String[]{'h10_additional_narrative','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] h11_corrected_data_type_info = new String[]{'h11_corrected_data','http://SFDC.biotronik.com',null,'1','1','false'};
	private String[] apex_schema_type_info = new String[]{'http://SFDC.biotronik.com','false','false'};
	private String[] field_order_type_info = new String[]{'mdrid','a1_patient_identifier','a2_patient_dob','a3_patient_gender','a3_patient_weight','a5_patient_ethnicgroup','a5_patient_racecode_asian','a5_patient_racecode_amindian','a5_patient_racecode_black','a5_patient_racecode_white','a5_patient_racecode_pacisland','b1_adverse_event','b1_product_problem','b2_adverse_event_death','b2_adverse_event_life_threat','b2_adverse_event_hospital','b2_adverse_event_req_intervent','b2_adverse_event_disability','b2_adverse_event_cong_anomaly','b2_adverse_event_other','b2_adverse_event_death_date','b3_date_of_event','b4_date_of_this_report','b5_describe_event_of_problem','d1_brand_name','d2_common_device_name','d2_common_device_name_pcode','d3_manufacturer_name','d3_manufacturer_street_line_1','d3_manufacturer_city','d3_manufacturer_state_code','d3_manufacturer_zip_code','d3_manufacturer_country_code','d4_model_number','d4_lot_number','d4_expiration_date','d4_serial_number','d4_other_number','d4_udi_number','d6_if_implanted_give_date','d7_if_explanted_give_date','d10_avail_for_evaluation','d10_avail_for_evaluation_date','e1_organization_name','e1_name_given_1','e1_name_family','e1_street_line_1','e1_city','e1_state_code','e1_zip_code','e1_country_code','e2_health_professional','e3_occupation','e4_also_sent_report_to_fda','f10_codes_patient_code_1','f10_codes_patient_code_2','f10_codes_patient_code_3','f10_codes_device_code_1','f10_codes_device_code_2','f10_codes_device_code_3','g1_contact_facility_name','g1_contact_street_line_1','g1_contact_city','g1_contact_state_code','g1_contact_zip_code','g1_contact_country_code','g1_contact_telecom_1','g3_report_src_foreign','g3_report_src_study','g3_report_src_literature','g3_report_src_consumer','g3_report_src_health_prof','g3_report_src_user_facility','g3_report_src_company_rep','g3_report_src_distributor','g3_report_src_other','g4_received_by_manuf_date','g5_pma_number','g7_type_of_report_5day','g7_type_of_report_7day','g7_type_of_report_10day','g7_type_of_report_15day','g7_type_of_report_30day','g7_type_of_report_periodic','g7_type_of_report_initial','g7_type_of_report_followup','g7_type_of_report_followup_num','g9_manufacturer_report_number','h1_type_of_report_event','h2_type_correction','h2_type_additional_information','h2_type_response_fda_request','h2_type_device_evaluation','h3_device_eval_by_manufacturer','h3_eval_summary_attached','h3_reason_for_non_eval_code','h3_reason_for_non_eval','h4_device_manufacture_date','h5_labeled_for_single_use','h6_evaluation_codes_method_1','h6_evaluation_codes_method_2','h6_evaluation_codes_method_3','h6_evaluation_codes_method_4','h6_evaluation_codes_results_1','h6_evaluation_codes_results_2','h6_evaluation_codes_results_3','h6_evaluation_codes_results_4','h6_evaluation_codes_conclusn_1','h6_evaluation_codes_conclusn_2','h6_evaluation_codes_conclusn_3','h6_evaluation_codes_conclusn_4','h7_remedial_action_init','h8_usage_of_device','h9_corrective_action_number','h10_additional_narrative','h11_corrected_data'};

	/*
	Make sure Objects passed in have related items fully populated
	*/
	public X5500_EMDR(complaint__c com, Analysis_Report__c ar, X5500_EMDRConfig__mdt config) {
        String mdrPrefix = config.mdr_prefix__c;
		this.mdrid = com.Id;
		//initial or followup report
		//boolean isFollowup = (com.type_of_report__c != null && com.type_of_report__c.toLowerCase().indexOf('Initial') != -1 ? false : true);
		boolean isFollowup = (com.type_of_report__c != null && com.type_of_report__c.containsIgnoreCase('initial') ? false : true);

		//Medwatch Section A
		this.a1_patient_identifier = com.patient_identifier__c;
		this.a2_patient_dob = (com.date_of_birth__c == null ? null : X5500_EMDR_Handler.formatEMDRDate(com.date_of_birth__c));
		this.a3_patient_gender = com.gender__c;
		this.a3_patient_weight = (com.patient_weight__c == null || com.patient_weight__c == 0 ? null : String.valueOf(com.patient_weight__c));
		this.a5_patient_ethnicgroup = com.ethnicity__c;

		/*this.a5_patient_racecode_asian = (com.race__c != null && com.race__c.toLowerCase().indexOf('asian') != -1 ? 'Asian' : null);
		this.a5_patient_racecode_amindian = (com.race__c != null && com.race__c.toLowerCase().indexOf('indian') != -1 ? 'AmericanIndianOrAlaskaNative' : null);
		this.a5_patient_racecode_black = (com.race__c != null && com.race__c.toLowerCase().indexOf('black') != -1 ? 'BlackOrAfricanAmerican' : null);
		this.a5_patient_racecode_white = (com.race__c != null && com.race__c.toLowerCase().indexOf('white') != -1 ? 'White' : null);
		this.a5_patient_racecode_pacisland = (com.race__c != null && com.race__c.toLowerCase().indexOf('pacific') != -1 ? 'NativeHawaiianOrOtherPacificIslander' : null);
		*/
		this.a5_patient_racecode_asian = (com.race__c != null && com.race__c.containsIgnoreCase('asian') ? 'Asian' : null);
		this.a5_patient_racecode_amindian = (com.race__c != null && com.race__c.containsIgnoreCase('indian') ? 'AmericanIndianOrAlaskaNative' : null);
		this.a5_patient_racecode_black = (com.race__c != null && com.race__c.containsIgnoreCase('black') ? 'BlackOrAfricanAmerican' : null);
		this.a5_patient_racecode_white = (com.race__c != null && com.race__c.containsIgnoreCase('white') ? 'White' : null);
		this.a5_patient_racecode_pacisland = (com.race__c != null && com.race__c.containsIgnoreCase('pacific') ? 'NativeHawaiianOrOtherPacificIslander' : null);

		//Medwatch Section B
		this.b1_adverse_event = (com.adverse_event__c != null && com.adverse_event__c == true ? 'YES' : 'NO');
		this.b1_product_problem = (com.product_problem__c != null && com.product_problem__c == true ? 'YES' : 'NO');
		//this.b2_adverse_event_death = (com.outcome_attributed_to_adverse_event__c != null && com.outcome_attributed_to_adverse_event__c.toLowerCase().indexOf('death') != -1 ? 'Death' : null);
		this.b2_adverse_event_death = (com.outcome_attributed_to_adverse_event__c != null && com.outcome_attributed_to_adverse_event__c.containsIgnoreCase('death') ? 'Death' : null);
		this.b2_adverse_event_death_date = (com.date_of_death__c == null ? null : X5500_EMDR_Handler.formatEMDRDate(com.date_of_death__c));
		/*
		this.b2_adverse_event_life_threat = (com.outcome_attributed_to_adverse_event__c != null && com.outcome_attributed_to_adverse_event__c.toLowerCase().indexOf('threat') != -1 ? 'LifeThreatening' : null);
		this.b2_adverse_event_hospital = (com.outcome_attributed_to_adverse_event__c != null && com.outcome_attributed_to_adverse_event__c.toLowerCase().indexOf('hospitalization') != -1 ? 'Hospitalization' : null);
		this.b2_adverse_event_req_intervent = (com.outcome_attributed_to_adverse_event__c != null && com.outcome_attributed_to_adverse_event__c.toLowerCase().indexOf('intervention') != -1 ? 'RequiredIntervention' : null);
		this.b2_adverse_event_disability = (com.outcome_attributed_to_adverse_event__c != null && com.outcome_attributed_to_adverse_event__c.toLowerCase().indexOf('disability') != -1 ? 'Disability' : null);
		this.b2_adverse_event_cong_anomaly = (com.outcome_attributed_to_adverse_event__c != null && com.outcome_attributed_to_adverse_event__c.toLowerCase().indexOf('congenital') != -1 ? 'CongenitalAnomaly' : null);
		this.b2_adverse_event_other = (com.outcome_attributed_to_adverse_event__c != null && com.outcome_attributed_to_adverse_event__c.toLowerCase().indexOf('other') != -1 ? 'Other' : null);
		*/
		this.b2_adverse_event_life_threat = (com.outcome_attributed_to_adverse_event__c != null && com.outcome_attributed_to_adverse_event__c.containsIgnoreCase('threat') ? 'LifeThreatening' : null);
		this.b2_adverse_event_hospital = (com.outcome_attributed_to_adverse_event__c != null && com.outcome_attributed_to_adverse_event__c.containsIgnoreCase('hospitalization') ? 'Hospitalization' : null);
		this.b2_adverse_event_req_intervent = (com.outcome_attributed_to_adverse_event__c != null && com.outcome_attributed_to_adverse_event__c.containsIgnoreCase('intervention') ? 'RequiredIntervention' : null);
		this.b2_adverse_event_disability = (com.outcome_attributed_to_adverse_event__c != null && com.outcome_attributed_to_adverse_event__c.containsIgnoreCase('disability') ? 'Disability' : null);
		this.b2_adverse_event_cong_anomaly = (com.outcome_attributed_to_adverse_event__c != null && com.outcome_attributed_to_adverse_event__c.containsIgnoreCase('congenital') ? 'CongenitalAnomaly' : null);
		this.b2_adverse_event_other = (com.outcome_attributed_to_adverse_event__c != null && com.outcome_attributed_to_adverse_event__c.containsIgnoreCase('other') ? 'Other' : null);

		this.b3_date_of_event = (com.date_of_event__c == null ? null : X5500_EMDR_Handler.formatEMDRDate(com.date_of_event__c));
		this.b4_date_of_this_report = (!isFollowup && com.report_date__c != null ? X5500_EMDR_Handler.formatEMDRDate(com.report_date__c) : isFollowup && com.followup_report_date__c != null ? X5500_EMDR_Handler.formatEMDRDate(com.followup_report_date__c) : null);
		this.b5_describe_event_of_problem = com.mdr_event_description__c;

		//Medwatch Section D
		this.d1_brand_name = com.asset__r.Name;
		//this.d2_common_device_name = com.asset__r.Product2.Family;
		this.d2_common_device_name = com.asset__r.product_type__c;
		this.d2_common_device_name_pcode = com.asset__r.Product2.ProductCode;
		this.d3_manufacturer_name = com.asset__r.Product2.manufacturer_account__r.Name;
		this.d3_manufacturer_street_line_1 = com.asset__r.Product2.manufacturer_account__r.shippingpostalcode;
		this.d3_manufacturer_city = com.asset__r.Product2.manufacturer_account__r.shippingcity;
		this.d3_manufacturer_state_code = com.asset__r.Product2.manufacturer_account__r.shippingstatecode;
		this.d3_manufacturer_zip_code = com.asset__r.Product2.manufacturer_account__r.shippingpostalcode;
		this.d3_manufacturer_country_code = (com.asset__r.Product2.manufacturer_account__r.shippingcountrycode == null ? null : com.asset__r.Product2.manufacturer_account__r.shippingcountrycode.left(3));
		this.d4_model_number = com.asset_model_number__c;
		this.d4_lot_number = com.asset_lot_number__c;
		this.d4_expiration_date = (com.expiration_date__c == null ? null : X5500_EMDR_Handler.formatEMDRDate(com.expiration_date__c));
		this.d4_serial_number = com.asset_serial_number__c;
		//this.D4_OTHER_NUMBER = null;//missing SFDC element to map to
		this.d4_udi_number = com.asset__r.UDI__c;
		this.d6_if_implanted_give_date = (com.asset_implant_date__c == null ? null : X5500_EMDR_Handler.formatEMDRDate(com.asset_implant_date__c));
		this.d7_if_explanted_give_date = (com.explant_date__c == null ? null : X5500_EMDR_Handler.formatEMDRDate(com.explant_date__c));
		this.d10_avail_for_evaluation = (com.device_available_for_evaluation__c == null ? null : com.device_available_for_evaluation__c == 'yes' ? 'YES' : com.device_available_for_evaluation__c == 'no' ? 'NO' : com.device_available_for_evaluation__c);
		this.d10_avail_for_evaluation_date = (com.date_product_returned_to_manufacturer__c == null ? null : X5500_EMDR_Handler.formatEMDRDate(com.date_product_returned_to_manufacturer__c));

		//Medwatch Section E
		this.e1_organization_name = com.initial_reporter_user__r.CompanyName;
		this.e1_name_given_1 = com.initial_reporter_user__r.FirstName;
		this.e1_name_family = com.initial_reporter_user__r.LastName;
		this.e1_street_line_1 = com.initial_reporter_user__r.Street;
		this.e1_city = com.initial_reporter_user__r.City;
		this.e1_state_code = com.initial_reporter_user__r.StateCode;
		this.e1_zip_code = com.initial_reporter_user__r.PostalCode;
		this.e1_country_code = com.initial_reporter_user__r.CountryCode;
		this.E2_HEALTH_PROFESSIONAL = (com.initial_reporter_user__r.health_professional__c != null && com.initial_reporter_user__r.health_professional__c == 'Yes' ? 'YES' : 'NO');
		//this.e3_occupation = com.initial_reporter_user__r.title;
		this.e3_occupation = String.isNotEmpty(config.occupation__c) ? config.occupation__c : 'OtherHealthCareProfessional';
		this.E4_ALSO_SENT_REPORT_TO_FDA = (com.initial_reporter_also_sent_report_to_fda__c != null ? com.initial_reporter_also_sent_report_to_fda__c : 'NO');

		//Medwatch Section F
		String[] patient_codes = (com.patient_code_global__c != null ? com.patient_code_global__c.split(';') : new String[]{null, null, null});
		this.f10_codes_patient_code_1 = (patient_codes[0] != null && patient_codes[0].isNumeric() ? patient_codes[0] : null);
		this.f10_codes_patient_code_2 = (patient_codes.size() > 1 && patient_codes[1] != null && patient_codes[1].isNumeric() ? patient_codes[1] : null);
		this.f10_codes_patient_code_3 = (patient_codes.size() > 2 && patient_codes[2] != null && patient_codes[2].isNumeric() ? patient_codes[2] : null);
		String[] device_codes = (com.device_code_global__c != null ? com.device_code_global__c.split(';') : new String[]{null, null, null});
		this.f10_codes_device_code_1 = (device_codes[0] != null && device_codes[0].isNumeric() ? device_codes[0] : null);
		this.f10_codes_device_code_2 = (device_codes.size() > 1 && device_codes[1] != null && device_codes[1].isNumeric() ? device_codes[1] : null);
		this.f10_codes_device_code_3 = (device_codes.size() > 2 && device_codes[2] != null && device_codes[2].isNumeric() ? device_codes[2] : null);

		//Medwatch Section G
		this.g1_contact_facility_name = config.g1_contact_facility_name__c;
		this.g1_contact_street_line_1 = config.g1_contact_street__c;
		this.g1_contact_city = config.g1_contact_city__c;
		this.g1_contact_state_code = config.g1_contact_state_code__c;
		this.g1_contact_zip_code = config.g1_contact_zip_code__c;
		this.g1_contact_country_code = config.g1_contact_country_code__c;
		this.g1_contact_telecom_1 = config.g1_contact_telecom__c;
		/*
		this.g3_report_src_foreign = (com.report_source__c != null && com.report_source__c.toLowerCase().indexOf('foreign') != -1 ? com.report_source__c : null);
		this.g3_report_src_study = (com.report_source__c != null && com.report_source__c.toLowerCase().indexOf('study') != -1 ? com.report_source__c : null);
		this.g3_report_src_literature = (com.report_source__c != null && com.report_source__c.toLowerCase().indexOf('literature') != -1 ? com.report_source__c : null);
		this.g3_report_src_consumer = (com.report_source__c != null && com.report_source__c.toLowerCase().indexOf('consumer') != -1 ? com.report_source__c : null);
		this.g3_report_src_health_prof = (com.report_source__c != null && com.report_source__c.toLowerCase().indexOf('professional') != -1 ? com.report_source__c : null);
		this.g3_report_src_user_facility = (com.report_source__c != null && com.report_source__c.toLowerCase().indexOf('facility') != -1 ? com.report_source__c : null);
		this.g3_report_src_company_rep = (com.report_source__c != null && com.report_source__c.toLowerCase().indexOf('represent') != -1 ? com.report_source__c : null);
		this.g3_report_src_distributor = (com.report_source__c != null && com.report_source__c.toLowerCase().indexOf('distributor') != -1 ? com.report_source__c : null);
		this.g3_report_src_other = (com.report_source__c != null && com.report_source__c.toLowerCase().indexOf('other') != -1 ? com.report_source__c : null);
		*/
		this.g3_report_src_foreign = (com.report_source__c != null && com.report_source__c.containsIgnoreCase('foreign') ? com.report_source__c : null);
		this.g3_report_src_study = (com.report_source__c != null && com.report_source__c.containsIgnoreCase('study') ? com.report_source__c : null);
		this.g3_report_src_literature = (com.report_source__c != null && com.report_source__c.containsIgnoreCase('literature') ? com.report_source__c : null);
		this.g3_report_src_consumer = (com.report_source__c != null && com.report_source__c.containsIgnoreCase('consumer') ? com.report_source__c : null);
		this.g3_report_src_health_prof = (com.report_source__c != null && com.report_source__c.containsIgnoreCase('professional') ? com.report_source__c : null);
		this.g3_report_src_user_facility = (com.report_source__c != null && com.report_source__c.containsIgnoreCase('facility') ? com.report_source__c : null);
		this.g3_report_src_company_rep = (com.report_source__c != null && com.report_source__c.containsIgnoreCase('represent') ? com.report_source__c : null);
		this.g3_report_src_distributor = (com.report_source__c != null && com.report_source__c.containsIgnoreCase('distributor') ? com.report_source__c : null);
		this.g3_report_src_other = (com.report_source__c != null && com.report_source__c.containsIgnoreCase('other') ? com.report_source__c : null);

		//this.g4_received_by_manuf_date = (com.mdr_report_date__c == null ? null : X5500_EMDR_Handler.formatEMDRDate(com.mdr_report_date__c));
		this.g4_received_by_manuf_date = (com.date_info_received_by_manufacturer__c == null ? null : X5500_EMDR_Handler.formatEMDRDate(com.date_info_received_by_manufacturer__c));
		this.g5_pma_number = com.pma_510k__c;

		/*
		this.g7_type_of_report_5day = (com.report_type_timing__c != null && com.report_type_timing__c.toLowerCase().indexOf('5 Day') != -1 ? 'FiveDayReport' : null);
		this.g7_type_of_report_7day = (com.report_type_timing__c != null && com.report_type_timing__c.toLowerCase().indexOf('7 Day') != -1 ? 'SevenDayReport' : null);
		this.g7_type_of_report_10day = (com.report_type_timing__c != null && com.report_type_timing__c.toLowerCase().indexOf('10 Day') != -1 ? 'TenDayReport' : null);
		this.g7_type_of_report_15day = (com.report_type_timing__c != null && com.report_type_timing__c.toLowerCase().indexOf('15 Day') != -1 ? 'FifteenDayReport' : null);
		this.g7_type_of_report_30day = (com.report_type_timing__c != null && com.report_type_timing__c.toLowerCase().indexOf('30 Day') != -1 ? 'ThirtyDayReport' : null);
		this.g7_type_of_report_periodic = (com.report_type_timing__c != null && com.report_type_timing__c.toLowerCase().indexOf('Periodic') != -1 ? 'PeriodicReport' : null);
		this.g7_type_of_report_initial = (com.type_of_report__c != null && com.type_of_report__c.toLowerCase().indexOf('Initial') != -1 ? 'InitialReport' : null);
		this.g7_type_of_report_followup = (com.type_of_report__c != null && com.type_of_report__c.toLowerCase().indexOf('Follow') != -1 ? 'FollowUpReport' : null);
		*/
		this.g7_type_of_report_5day = (com.mdr_decision__c != null && com.mdr_decision__c.containsIgnoreCase('5 calendar day') ? 'FiveDayReport' : null);
		this.g7_type_of_report_7day = (com.mdr_decision__c != null && com.mdr_decision__c.containsIgnoreCase('7 calendar day') ? 'SevenDayReport' : null);
		this.g7_type_of_report_10day = (com.mdr_decision__c != null && com.mdr_decision__c.containsIgnoreCase('10 calendar day') ? 'TenDayReport' : null);
		this.g7_type_of_report_15day = (com.mdr_decision__c != null && com.mdr_decision__c.containsIgnoreCase('15 calendar day') ? 'FifteenDayReport' : null);
		this.g7_type_of_report_30day = (com.mdr_decision__c != null && com.mdr_decision__c.containsIgnoreCase('30 calendar day') ? 'ThirtyDayReport' : null);
		this.g7_type_of_report_periodic = (com.mdr_decision__c != null && com.mdr_decision__c.containsIgnoreCase('Periodic') ? 'PeriodicReport' : null);
		this.g7_type_of_report_initial = (com.type_of_report__c != null && com.type_of_report__c.containsIgnoreCase('Initial') ? 'InitialReport' : null);
		this.g7_type_of_report_followup = (com.type_of_report__c != null && com.type_of_report__c.containsIgnoreCase('Follow') ? 'FollowUpReport' : null);

		this.g7_type_of_report_followup_num = (com.type_of_report_follow_up__c == null ? null : String.valueOf(com.type_of_report_follow_up__c));
		this.g9_manufacturer_report_number = com.mdr_number__c;

		//Medwatch Section H
		this.h1_type_of_report_event = com.type_of_reportable_event__c;
		/*
		this.h2_type_correction = (com.if_follow_up_what_type__c != null && com.if_follow_up_what_type__c.toLowerCase().indexOf('Correction') != -1 ? 'CorrectionReport' : null);
		this.h2_type_additional_information = (com.if_follow_up_what_type__c != null && com.if_follow_up_what_type__c.toLowerCase().indexOf('Additional') != -1 ? 'AdditionalInformationReport' : null);
		this.h2_type_response_fda_request = (com.if_follow_up_what_type__c != null && com.if_follow_up_what_type__c.toLowerCase().indexOf('FDA') != -1 ? 'ResponseToFDARequest' : null);
		this.h2_type_device_evaluation = (com.if_follow_up_what_type__c != null && com.if_follow_up_what_type__c.toLowerCase().indexOf('Device') != -1 ? 'DeviceEvaluation' : null);
		*/
		this.h2_type_correction = (com.if_follow_up_what_type__c != null && com.if_follow_up_what_type__c.containsIgnoreCase('Correction') ? 'CorrectionReport' : null);
		this.h2_type_additional_information = (com.if_follow_up_what_type__c != null && com.if_follow_up_what_type__c.containsIgnoreCase('Additional') ? 'AdditionalInformationReport' : null);
		this.h2_type_response_fda_request = (com.if_follow_up_what_type__c != null && com.if_follow_up_what_type__c.containsIgnoreCase('FDA') ? 'ResponseToFDARequest' : null);
		this.h2_type_device_evaluation = (com.if_follow_up_what_type__c != null && com.if_follow_up_what_type__c.containsIgnoreCase('Device') ? 'DeviceEvaluation' : null);

		this.h3_device_eval_by_manufacturer = ar.device_evaluated_by_manufacturer__c;
		this.h3_eval_summary_attached = (com.evaluation_summary_attached__c == true ? 'Y' : 'N');
		this.h3_reason_for_non_eval_code = null;
		this.h3_reason_for_non_eval = null;
		this.h4_device_manufacture_date = (com.date_of_manufacture__c == null ? null : X5500_EMDR_Handler.formatEMDRDate(com.date_of_manufacture__c));
		this.h5_labeled_for_single_use = (com.labeled_for_single_use__c == true ? 'YES' : 'NO');
		String[] method_codes = (ar.method_code__c != null ? ar.method_code__c.split(';') : new String[]{null, null, null, null});
		this.h6_evaluation_codes_method_1 = (method_codes[0] != null ? method_codes[0] : null);
		this.h6_evaluation_codes_method_2 = (method_codes.size() > 1 && method_codes[1] != null ? method_codes[1] : null);
		this.h6_evaluation_codes_method_3 = (method_codes.size() > 2 && method_codes[2] != null ? method_codes[2] : null);
		this.h6_evaluation_codes_method_4 = (method_codes.size() > 3 && method_codes[3] != null ? method_codes[3] : null);
		String[] result_codes = (ar.result_code__c != null ? ar.result_code__c.split(';') : new String[]{null, null, null, null});
		this.h6_evaluation_codes_results_1 = (result_codes[0] != null ? result_codes[0] : null);
		this.h6_evaluation_codes_results_2 = (result_codes.size() > 1 && result_codes[1] != null ? result_codes[1] : null);
		this.h6_evaluation_codes_results_3 = (result_codes.size() > 2 && result_codes[2] != null ? result_codes[2] : null);
		this.h6_evaluation_codes_results_4 = (result_codes.size() > 3 && result_codes[3] != null ? result_codes[3] : null);
		String[] conclusion_codes = (ar.conclusion_code__c != null ? ar.conclusion_code__c.split(';') : new String[]{null, null, null, null});
		this.h6_evaluation_codes_conclusn_1 = (conclusion_codes[0] != null ? conclusion_codes[0] : null);
		this.h6_evaluation_codes_conclusn_2 = (conclusion_codes.size() > 1 && conclusion_codes[1] != null ? conclusion_codes[1] : null);
		this.h6_evaluation_codes_conclusn_3 = (conclusion_codes.size() > 2 && conclusion_codes[2] != null ? conclusion_codes[2] : null);
		this.h6_evaluation_codes_conclusn_4 = (conclusion_codes.size() > 3 && conclusion_codes[3] != null ? conclusion_codes[3] : null);
		this.h7_remedial_action_init = com.remedial_action_type__c;
		this.h8_usage_of_device = com.usage_of_device__c;
		this.h10_additional_narrative = com.additional_manufacturer_narrative__c;
		//this.h10_additional_narrative = (this.h10_additional_narrative != null && ar.analysis_results__c != null ? this.h10_additional_narrative + '\n\n' + ar.analysis_results__c : this.h10_additional_narrative == null && ar.analysis_results__c != null ? ar.analysis_results__c : this.h10_additional_narrative);
		this.h11_corrected_data = com.corrected_data_comment__c;
	}

}
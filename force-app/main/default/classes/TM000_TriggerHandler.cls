/**
 * @author Erwan Yhuellou
 * @created 13/01/2020
 * @description Trigger action handler
 */
public without sharing virtual class TM000_TriggerHandler {

	public static Boolean ByPassAllTriggers = false;

	// the current context of the trigger, overridable in tests
	@TestVisible
	private TriggerContext context;

	// the current context of the trigger, overridable in tests
	@TestVisible
	private Boolean isTriggerExecuting;

	// constructor
	public TM000_TriggerHandler() {
		this.setTriggerContext();
	}



	/***************************************
	 * public instance methods
	 ***************************************/

	// main method that will be called during execution
	public void run() {
		System.debug('>> TM000_TriggerHandler - run : enter the run trigger');
		if(!validateRun()) return;
		System.debug('>> TM000_TriggerHandler - run : Trigger is validated');

		// dispatch to the correct handler method
		if(this.context == TriggerContext.BEFORE_INSERT) {
			this.beforeInsert();
		} else if(this.context == TriggerContext.BEFORE_UPDATE) {
			this.beforeUpdate();
		} else if(this.context == TriggerContext.BEFORE_DELETE) {
			this.beforeDelete();
		} else if(this.context == TriggerContext.AFTER_INSERT) {
			this.afterInsert();
		} else if(this.context == TriggerContext.AFTER_UPDATE) {
			this.afterUpdate();
		} else if(this.context == TriggerContext.AFTER_DELETE) {
			this.afterDelete();
		} else if(this.context == TriggerContext.AFTER_UNDELETE) {
			this.afterUndelete();
		}

	}

	/***************************************
	 * private instancemethods
	 ***************************************/

	@TestVisible
	private void setTriggerContext() {
		this.setTriggerContext(null, false);
	}

	@TestVisible
	private void setTriggerContext(String ctx, Boolean testMode) {
		if(!Trigger.isExecuting && !testMode) {
			this.isTriggerExecuting = false;
			return;
		} else {
			this.isTriggerExecuting = true;
		}

		if((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
				(ctx != null && ctx == 'before insert')) {
			this.context = TriggerContext.BEFORE_INSERT;
		} else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
				(ctx != null && ctx == 'before update')){
			this.context = TriggerContext.BEFORE_UPDATE;
		} else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
				(ctx != null && ctx == 'before delete')) {
			this.context = TriggerContext.BEFORE_DELETE;
		} else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
				(ctx != null && ctx == 'after insert')) {
			this.context = TriggerContext.AFTER_INSERT;
		} else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
				(ctx != null && ctx == 'after update')) {
			this.context = TriggerContext.AFTER_UPDATE;
		} else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
				(ctx != null && ctx == 'after delete')) {
			this.context = TriggerContext.AFTER_DELETE;
		} else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
				(ctx != null && ctx == 'after undelete')) {
			this.context = TriggerContext.AFTER_UNDELETE;
		}
	}

	// make sure this trigger should continue to run
	@TestVisible
	private Boolean validateRun() {
		if(!this.isTriggerExecuting || this.context == null) {
			throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
		}
        /*
		CORE_ExecutionSettings__c executionSetting = CORE_ExecutionSettings__c.getInstance();
		Boolean userByPassTriggers = executionSetting.CORE_ByPassAllTriggers__c;

		if(userByPassTriggers == true || TM000_TriggerHandler.ByPassAllTriggers == true || TM000_TriggerHandler.bypassedHandlers.contains(getHandlerName())) {
			return false;
		}*/
		return true;
	}

	@TestVisible
	private String getHandlerName() {
		System.debug('>> TM000_TriggerHandler - getHandlerName : ' + String.valueOf(this));
		return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
	}

	/***************************************
	 * context methods
	 ***************************************/

	// context-specific methods for override
	@TestVisible
	protected virtual void beforeInsert(){}
	@TestVisible
	protected virtual void beforeUpdate(){}
	@TestVisible
	protected virtual void beforeDelete(){}
	@TestVisible
	protected virtual void afterInsert(){}
	@TestVisible
	protected virtual void afterUpdate(){}
	@TestVisible
	protected virtual void afterDelete(){}
	@TestVisible
	protected virtual void afterUndelete(){}

	/***************************************
	 * inner classes
	 ***************************************/

	// possible trigger contexts
	@TestVisible
	private enum TriggerContext {
		BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
		AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
		AFTER_UNDELETE
	}

	// exception class
	public class TriggerHandlerException extends Exception {}

}
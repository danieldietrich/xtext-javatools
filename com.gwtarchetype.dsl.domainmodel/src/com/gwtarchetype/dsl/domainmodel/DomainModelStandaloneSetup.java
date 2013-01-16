
package com.gwtarchetype.dsl.domainmodel;

/**
 * Initialization support for running Xtext languages 
 * without equinox extension registry
 */
public class DomainModelStandaloneSetup extends DomainModelStandaloneSetupGenerated{

	public static void doSetup() {
		new DomainModelStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}


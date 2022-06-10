import Quick
import Nimble

@testable import animeal

class LoginViewModelTestsSpec: QuickSpec {

    override func spec() {

        var sut: LoginViewModel!
        var model: LoginModelProtocolMock!
        var actionsMapper: LoginViewActionMappableMock!
        var onboardingMapper: LoginViewOnboardingStepsMappableMock!

        describe("LoginViewModel") {

            beforeEach {
                model = LoginModelProtocolMock()
                model.fetchOnboardingStepsClosure = { [] }
                model.fetchActionsClosure = { [] }

                actionsMapper = LoginViewActionMappableMock()
                actionsMapper.mapActionsClosure = { _ in [] }

                onboardingMapper = LoginViewOnboardingStepsMappableMock()
                onboardingMapper.mapStepsClosure = { _ in [] }

                sut = LoginViewModel(
                    model: model,
                    actionsMapper: actionsMapper,
                    onboardingMapper: onboardingMapper
                )
            }

            context("when load() is called") {
                beforeEach {
                    sut.load()
                }

                it("then fetchOnboardingSteps() is called on model one time") {
                    expect(model.fetchOnboardingStepsCalled).to(beTrue())
                    expect(model.fetchOnboardingStepsCallsCount).to(equal(1))
                }

                it("then fetchActions() is called on model one time") {
                    expect(model.fetchActionsCalled).to(beTrue())
                    expect(model.fetchActionsCallsCount).to(equal(1))
                }

                it("then mapSteps() is called on onboardingMapper one time") {
                    expect(onboardingMapper.mapStepsCalled).to(beTrue())
                    expect(onboardingMapper.mapStepsCallsCount).to(equal(1))
                }

                it("then mapActions() is called on actionsMapper one time") {
                    expect(actionsMapper.mapActionsCalled).to(beTrue())
                    expect(actionsMapper.mapActionsCallsCount).to(equal(1))
                }
            }
        }
    }
}

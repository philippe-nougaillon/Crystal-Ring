require 'test_helper'

class FacturesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @facture = factures(:one)
  end

  test "should get index" do
    get factures_url
    assert_response :success
  end

  test "should get new" do
    get new_facture_url
    assert_response :success
  end

  test "should create facture" do
    assert_difference('Facture.count') do
      post factures_url, params: { facture: { anomalie: @facture.anomalie, cible: @facture.cible, etat: @facture.etat, num_chrono: @facture.num_chrono, par: @facture.par, société: @facture.société } }
    end

    assert_redirected_to facture_url(Facture.last)
  end

  test "should show facture" do
    get facture_url(@facture)
    assert_response :success
  end

  test "should get edit" do
    get edit_facture_url(@facture)
    assert_response :success
  end

  test "should update facture" do
    patch facture_url(@facture), params: { facture: { anomalie: @facture.anomalie, cible: @facture.cible, etat: @facture.etat, num_chrono: @facture.num_chrono, par: @facture.par, société: @facture.société } }
    assert_redirected_to facture_url(@facture)
  end

  test "should destroy facture" do
    assert_difference('Facture.count', -1) do
      delete facture_url(@facture)
    end

    assert_redirected_to factures_url
  end
end
